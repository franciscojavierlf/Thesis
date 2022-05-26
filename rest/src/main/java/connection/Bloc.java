package connection;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.Network;

import javax.json.Json;
import javax.json.JsonObjectBuilder;

public final class Bloc {
  private static CryptoBridge bridge = new CryptoBridge();

  public void connect() throws Exception {
    bridge.connect();
  }

  public JsonArray queryAllWallets() throws Exception {
    // create a gateway connection
    Gateway gateway = bridge.getBuilder().connect();
    // get the network and contract
    Network network = gateway.getNetwork(bridge.channel);
    Contract contract = network.getContract(bridge.contract);
    byte[] result = contract.evaluateTransaction("QueryAllWallets");
    JsonParser parser = new JsonParser();
    JsonArray json = (JsonArray) parser.parse(new String(result));
    return json;
  }

  public JsonObject queryWallet(String walletId) throws Exception {
    // create a gateway connection
    Gateway gateway = bridge.getBuilder().connect();
    // get the network and contract
    Network network = gateway.getNetwork(bridge.channel);
    Contract contract = network.getContract(bridge.contract);

    byte[] result = contract.evaluateTransaction("QueryWallet", walletId);
    JsonParser parser = new JsonParser();
    JsonObject json = (JsonObject) parser.parse(new String(result));
    return json;
  }

  public JsonArray queryTrajectories(String walletId) throws Exception {
    // create a gateway connection
    Gateway gateway = bridge.getBuilder().connect();
    // get the network and contract
    Network network = gateway.getNetwork(bridge.channel);
    Contract contract = network.getContract(bridge.contract);

    byte[] result = contract.evaluateTransaction("QueryTrajectories", walletId);
    JsonParser parser = new JsonParser();
    JsonArray json = (JsonArray) parser.parse(new String(result));
    return json;
  }

  /**
   * Adds a new trajectory.
   * @param jsonString
   * @return
   */
  public JsonObject addTrajectory(String walletId, String jsonString) throws Exception {
    // create a gateway connection
    Gateway gateway = bridge.getBuilder().connect();

    // get the network and contract
    Network network = gateway.getNetwork(bridge.channel);
    Contract contract = network.getContract(bridge.contract);

    // Transaction
    byte[] result = contract.createTransaction("AddTrajectory")
      .submit(walletId, jsonString);
    JsonParser parser = new JsonParser();
    JsonObject json = (JsonObject) parser.parse(new String(result));
    return json;
  }
}
