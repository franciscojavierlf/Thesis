/*
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"encoding/json"
	"fmt"
	"math"
	"errors"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/google/uuid"
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
	Id 						string `json:"id"`
	Finish 				uint64 `json:"finish"`
	Tokens 				float64 `json:"tokens"`
	CarbonEmitted float64 `json:"carbonEmitted"`
	CarbonSaved 	float64 `json:"carbonSaved"`
	Distance 			float64 `json:"distance"`
	Duration 			uint64 `json:"duration"`
	Path 					[][]float64 `json:"path"`
	Transport 		string `json:"transport"`
	Owner 				string `json:"owner"`
	Type 					string `json:"type"`
}

// Defines a new trajectory that a user sends
type NewTrajectory struct {
	Duration 	uint64 `json:"duration"`
	Finish 		uint64 `json:"finish"`
	Path 			[][]float64 `json:"path"`
	Transport string `json:"transport"`
}

type Wallet struct {
	Id											string `json:"id"`
	Tokens 									float64 `json:"tokens"`
	CarbonEmitted 					map[string]float64 `json:"carbonEmitted"`
	CarbonSaved 						map[string]float64 `json:"carbonSaved"`
	TimeTravelled 					map[string]float64 `json:"timeTravelled"`
	DistanceTravelled 			map[string]float64 `json:"distanceTravelled"`
	TotalDistanceTravelled 	float64 `json:"totalDistanceTravelled"`
	TotalCarbonSaved 				float64 `json:"totalCarbonSaved"`
	TotalCarbonEmitted 			float64 `json:"totalCarbonEmitted"`
	TotalTimeTravelled 			uint64 `json:"totalTimeTravelled"`
	Type 										string `json:"type"`
}

// Structure used for handling result of a wallet's query
type WalletQueryResult struct {
	Key     string `json:"key"`
	Record *Wallet
}

// Structure used for handling result of trajectory's query
type TrajectoryQueryResult struct {
	Key			string `json:"key"`
	Record *Trajectory	
}

// InitLedger adds a base set of cars to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {

	// Adds a single wallet
	wallet := Wallet{
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
		Type: "wallet",
	}

	walletAsBytes, _ := json.Marshal(wallet)
	err := ctx.GetStub().PutState(wallet.Id, walletAsBytes)

	if err != nil {
		return fmt.Errorf("Failed to put to world state. %s", err.Error())
	}

	// Adds trajectories
	trajectories := []Trajectory{
		Trajectory{
			Id: "FLBPfISN54AezuuAdwjb",
			Finish: 1637132794000,
			Tokens: 23,
			CarbonEmitted: 0.1,
			CarbonSaved: 3.4,
			Distance: 0.8,
			Duration: 389000,
			Path: [][]float64{{19.2309, 99.0914}, {19.2257, 99.0919}},
			Transport: "Transport.Walking",
			Owner: "c0QOCSutCq82DfIyXBfj",
			Type: "trajectory",
		},
		Trajectory{
			Id: "kY0SZtn4aBUHBQJ05Tjk",
			Finish: 1637132794000,
			Tokens: 0,
			CarbonEmitted: 0.0010551622068544642,
			CarbonSaved: 0.0010551622068544642,
			Distance: 0.043121996659537594,
			Duration: 69476,
			Path: [][]float64{{19.2309, 99.0914}, {19.2257, 99.0919}},
			Transport: "Transport.Walking",
			Owner: "c0QOCSutCq82DfIyXBfj",
			Type: "trajectory",
		},
	}
	
	for _, trajectory := range trajectories {
		trajectoryAsBytes, _ := json.Marshal(trajectory)
		err := ctx.GetStub().PutState(trajectory.Id, trajectoryAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

func (s *SmartContract) AddTrajectory(ctx contractapi.TransactionContextInterface, walletId string, jsonString string) error {

	id := uuid.New().String()

	// Converts to json
	var trajectoryData NewTrajectory
	json.Unmarshal([]byte(jsonString), &trajectoryData)

	// Logic behind the incentive
	if trajectoryData.Transport == "Transport.Car" {
		return errors.New("Cannot add a trajectory with a car!")
	}
	if !isTransportValid(trajectoryData.Transport) {
		return errors.New("Transport is not valid: " + trajectoryData.Transport)
	}
	if len(trajectoryData.Path) < 2 {
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
	for i := 1; i < len(trajectoryData.Path); i++ {
		distance += getDistance(trajectoryData.Path[i - 1], trajectoryData.Path[i])
	}

	// Calculates important data
	carbonEmitted := distance / float64(trajectoryData.Duration) * 1000
	carbonSaved := distance / float64(trajectoryData.Duration) * 1000
	switch trajectoryData.Transport {
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
		Finish: trajectoryData.Finish,
		Tokens: tokens,
		CarbonEmitted: carbonEmitted,
		CarbonSaved: carbonSaved,
		Distance: distance,
		Duration: trajectoryData.Duration,
		Path: trajectoryData.Path,
		Transport: trajectoryData.Transport,
		Owner: walletId,
		Type: "trajectory",
	}

	trajectoryAsBytes, _ := json.Marshal(trajectory)
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
	wallet.TotalTimeTravelled += trajectoryData.Duration

	walletAsBytes, _ := json.Marshal(wallet)
	return ctx.GetStub().PutState(walletId, walletAsBytes)
}

func (s *SmartContract) AddEmptyWallet(ctx contractapi.TransactionContextInterface, id string) error {
	
	wallet := Wallet{
		Id: id,
		Tokens: 0.0,
		CarbonEmitted: map[string]float64{},
		CarbonSaved: map[string]float64{},
		TimeTravelled: map[string]float64{},
		DistanceTravelled: map[string]float64{},
		TotalDistanceTravelled: 0.0,
		TotalCarbonSaved: 0.0,
		TotalCarbonEmitted: 0.0,
		TotalTimeTravelled: 0,
		Type: "wallet",
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

// Returns all trajectories from a wallet.
func (s *SmartContract) QueryTrajectories(ctx contractapi.TransactionContextInterface, walletId string) ([]TrajectoryQueryResult, error) {

	// Creates a couchdb query
	query := fmt.Sprintf(`{"selector":{"type":"trajectory","owner":"%s"}}`, walletId)
	resultsIterator, err := ctx.GetStub().GetQueryResult(query)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []TrajectoryQueryResult{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		trajectory := new(Trajectory)
		_ = json.Unmarshal(queryResponse.Value, trajectory)

		queryResult := TrajectoryQueryResult{Key: queryResponse.Key, Record: trajectory}
		results = append(results, queryResult)
	}

	return results, nil
}

// Returns all wallets found in world state.
func (s *SmartContract) QueryAllWallets(ctx contractapi.TransactionContextInterface) ([]WalletQueryResult, error) {

	query := fmt.Sprintf(`{"selector":{"type":"wallet"}}`)
	resultsIterator, err := ctx.GetStub().GetQueryResult(query)

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
