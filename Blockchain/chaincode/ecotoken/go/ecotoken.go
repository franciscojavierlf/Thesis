/*
SPDX-License-Identifier: Apache-2.0

*/

package main

import (
	"encoding/json"
	"fmt"
	"strconv"
	"math"

	"errors"
	"bytes"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"	
)

// SmartContract provides functions for managing trajectories and transactions
type SmartContract struct {
	contractapi.Contract
}

// Enum of transport types
const (
	Motorcycle string = "Transport.Motorcycle"
	Walking string		= "Transport.Walking"
	Metro string			= "Transport.Metro"
	Bus string				= "Transport.Bus"
	Bicycle string		= "Transport.Bicycle"
	Car string				= "Transport.Car"
)

// A list of all the possible transports
func isTransportValid(transport string) bool {
	switch transport {
		case 
			Motorcycle,
			Walking,
			Metro,
			Bus,
			Bicycle,
			Car:
				return true
		}
	return false
}

// Describes a trajectory
type Trajectory struct {
	Id 						string `json:"Id"`
	Finish 				uint32 `json:"Finish"`
	Tokens 				float64 `json:"Tokens"`
	CarbonEmitted float64 `json:"CarbonEmitted"`
	CarbonSaved 	float64 `json:"CarbonSaved"`
	Distance 			float64 `json:"Distance"`
	Duration 			uint32 `json:"Duration"`
	Path 					[][]float64 `json:"Path"`
	Transport 		string `json:"Transport"`
	Owner 				string `json:"Owner"`
}

type Wallet struct {
	Id											string `json:"Id"`
	Tokens 									float64 `json:"Tokens"`
	CarbonEmitted 					map[string]float64 `json:"CarbonEmitted"`
	CarbonSaved 						map[string]float64 `json:"CarbonSaved"`
	TimeTravelled 					map[string]float64 `json:"TimeTravelled"`
	DistanceTravelled 			map[string]float64 `json:"DistanceTravelled"`
	TotalDistanceTravelled 	float64 `json:"TotalDistanceTravelled"`
	TotalCarbonSaved 				float64 `json:"TotalCarbonSaved"`
	TotalCarbonEmitted 			float64 `json:"TotalCarbonEmitted"`
	TotalTimeTravelled 			uint32 `json:"TotalTimeTravelled"`
}

// Structure used for handling result of a wallet's query
type WalletQueryResult struct {
	Key     string `json:"Key"`
	Record *Wallet
}

// Structure used for handling result of trajectory's query
type TrajectoryQueryResult struct {
	Key			string `json:"Key"`
	Record *Trajectory	
}

// InitLedger adds a base set of cars to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {

	wallets := []Wallet {
		Wallet{
			Id: "c0QOCSutCq82DfIyXBfj",
			Tokens: 23.0,
			CarbonEmitted: map[string]float64{
				"Transport.Walking": 0.1,
			},
			CarbonSaved: map[string]float64{
				"Transport.Walking": 2.3,
			},
			TimeTravelled: map[string]float64{
				"Transport.Walking": 389000,
			},
			DistanceTravelled: map[string]float64{
				"Transport.Walking": 0.8,
			},
			TotalDistanceTravelled: 0.916,
			TotalCarbonSaved: 2.31,
			TotalCarbonEmitted: 0.11,
			TotalTimeTravelled: 485243,
		},
	}

	for _, wallet := range wallets {
		walletAsBytes, _ := json.Marshal(wallet)
		err := ctx.GetStub().PutState(wallet.Id, walletAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

func (s *SmartContract) AddTrajectory(ctx contractapi.TransactionContextInterface, id string, walletId string, owner string, duration uint32, finish uint32, path [][]float64, transport string) error {
	// Logic behind the incentive
	if transport == "Transport.Car" {
		return errors.New("Cannot add a trajectory with a car!")
	}
	if !isTransportValid(transport) {
		return errors.New("Transport is not valid: " + transport)
	}
	if len(path) < 2 {
		return errors.New("Path must contain at least two points!")
	}

	// Calculates distance between two geopoints
	getDistance := func(p1 []float64, p2 []float64) float64 {
		lat1 := p1[0]; lat2 := p2[0];
		lon1 := p1[1]; lon2 := p2[1];
		return 6371 * 2 * math.Asin(math.Sqrt(math.Pow(math.Sin((lat2 - lat1) * 0.5), 2) + math.Cos(lat1) * math.Cos(lat2) * math.Pow(math.Sin((lon2 - lon1) * 0.5), 2)))
	}

	// Gets total distance
	var distance float64 = 0.0
	for i := 1; i < len(path); i++ {
		distance += getDistance(path[i - 1], path[i])
	}

	// Calculates important data
	carbonEmitted := distance / float64(duration) * 1000
	carbonSaved := distance / float64(duration) * 1000
	switch transport {
		case Motorcycle:
			carbonEmitted *= 0.4
			carbonSaved *= 0.4
		case Metro:
			carbonEmitted *= 1.1
			carbonSaved *= 1.1
		case Bus:
			carbonEmitted *= 0.9
			carbonSaved *= 0.9
		case Walking, Bicycle:
			carbonEmitted *= 1.7
			carbonSaved *= 1.7
	}

	// Calculates the tokens that are going to be given
	tokens := carbonSaved - carbonEmitted

	// Creates the trajectory
	trajectory := Trajectory{
		Finish: finish,
		Tokens: tokens,
		CarbonEmitted: carbonEmitted,
		CarbonSaved: carbonSaved,
		Distance: distance,
		Duration: duration,
		Path: path,
		Transport: transport,
		Owner: owner,
	}

	trajectoryAsBytes, _ := json.Marshal(trajectory)

	////////// FALTA PONER ID
	ctx.GetStub().PutState(id, trajectoryAsBytes)

	// After adding trajectory, we add the update into the wallet
	wallet, err := s.QueryWallet(ctx, walletId)
	if err != nil {
		return err
	}

	wallet.Tokens += tokens
	wallet.TotalCarbonSaved += carbonSaved
	wallet.TotalCarbonEmitted += carbonEmitted
	wallet.TotalDistanceTravelled += distance
	wallet.TotalTimeTravelled += duration

	walletAsBytes, _ := json.Marshal(wallet)
	return ctx.GetStub().PutState(walletId, walletAsBytes)
}

func (s *SmartContract) AddEmptyWallet(ctx contractapi.TransactionContextInterface, id string) error {
	
	wallet := Wallet{
		Id: "c0QOCSutCq82DfIyXBfj",
		Tokens: 0.0,
		CarbonEmitted: map[string]float64{},
		CarbonSaved: map[string]float64{},
		TimeTravelled: map[string]float64{},
		DistanceTravelled: map[string]float64{},
		TotalDistanceTravelled: 0.0,
		TotalCarbonSaved: 0.0,
		TotalCarbonEmitted: 0.0,
		TotalTimeTravelled: 0,
	}

	walletAsBytes, _ := json.Marshal(wallet)
	err := ctx.GetStub().PutState(wallet.Id, walletAsBytes)

	if err != nil {
		return fmt.Errorf("Failed to put to world state. %s", err.Error())
	}
	return nil
}

// Returns a wallet.
func (s *SmartContract) QueryWallet(ctx contractapi.TransactionContextInterface, walletId string) (*Wallet, error) {
	walletAsBytes, err := ctx.GetStub().GetState(walletId)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if walletAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", walletId)
	}

	wallet := new(Wallet)
	_ = json.Unmarshal(walletAsBytes, wallet)

	return wallet, nil
}

// Returns all wallets found in world state.
func (s *SmartContract) QueryAllWallets(ctx contractapi.TransactionContextInterface) ([]WalletQueryResult, error) {
	startKey := ""
	endKey := ""

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []WalletQueryResult{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		wallet := new(Wallet)
		_ = json.Unmarshal(queryResponse.Value, wallet)

		queryResult := WalletQueryResult{Key: queryResponse.Key, Record: wallet}
		results = append(results, queryResult)
	}

	return results, nil
}

// GetHistoryCar gets the transaction history of a given car
func (s *SmartContract) GetHistory(ctx contractapi.TransactionContextInterface, key string) (string, error) {

	existing, err := ctx.GetStub().GetState(key)

	if err != nil {
		return "", errors.New("Unable to interact with world state")
	}

	if existing == nil {
		return "", fmt.Errorf("Cannot read world state with key %s. Does not exist", key)
	}

	stub := ctx.GetStub()

	assetID := key

	fmt.Printf("- start GetHistory Car: %s\n", assetID)

	resultsIterator, err := stub.GetHistoryForKey(assetID)
	if err != nil {
		return "", errors.New("Unable to get history")
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return "", errors.New("Unable to get next element ") //(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- GetHistory returning:\n%s\n", buffer.String())
	return buffer.String(), nil
}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create ecotoken chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting ecotoken chaincode: %s", err.Error())
	}
}
