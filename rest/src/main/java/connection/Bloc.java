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

  public JsonArray queryAllWallets() {
    byte[] result = null;
    // create a gateway connection
    try (Gateway gateway = bridge.getBuilder().connect()) {
      // get the network and contract
      Network network = gateway.getNetwork(bridge.channel);
      Contract contract = network.getContract(bridge.contract);

      result = contract.evaluateTransaction("QueryAllWallets");
      JsonParser parser = new JsonParser();
      JsonArray json = (JsonArray) parser.parse(new String(result));
      return json;
    }catch(Exception e) {
      System.out.println(" ############# ERROR ############## ");
      e.printStackTrace();
      System.out.println(" ############# ERROR ############## ");
    }
    return new JsonArray();
  }

  public JsonObject queryWallet(String walletId) {
    byte[] result = null;
    // create a gateway connection
    try (Gateway gateway = bridge.getBuilder().connect()) {
      // get the network and contract
      Network network = gateway.getNetwork(bridge.channel);
      Contract contract = network.getContract(bridge.contract);

      result = contract.evaluateTransaction("QueryWallet", walletId);
      JsonParser parser = new JsonParser();
      JsonObject json = (JsonObject) parser.parse(new String(result));
      return json;
    }catch(Exception e) {
      System.out.println(" ############# ERROR ############## ");
      e.printStackTrace();
      System.out.println(" ############# ERROR ############## ");
    }
    return new JsonObject();
  }

  public JsonArray queryTrajectories(String walletId) {
    byte[] result = null;
    // create a gateway connection
    try (Gateway gateway = bridge.getBuilder().connect()) {
      // get the network and contract
      Network network = gateway.getNetwork(bridge.channel);
      Contract contract = network.getContract(bridge.contract);

      result = contract.evaluateTransaction("QueryTrajectories", walletId);
      JsonParser parser = new JsonParser();
      JsonArray json = (JsonArray) parser.parse(new String(result));
      return json;
    }catch(Exception e) {
      System.out.println(" ############# ERROR ############## ");
      e.printStackTrace();
      System.out.println(" ############# ERROR ############## ");
    }
    return new JsonArray();
  }

  /**
   * Adds a new trajectory.
   * @param jsonString
   * @return
   */
  public boolean addTrajectory(String jsonString) {

    // create a gateway connection
    try (Gateway gateway = bridge.getBuilder().connect()) {

      // get the network and contract
      Network network = gateway.getNetwork(bridge.channel);
      Contract contract = network.getContract(bridge.contract);

      // Transaction
      byte[] createResult = contract.createTransaction("AddTrajectory")
        .submit(jsonString);

      System.out.println(" ############# Result ############## ");
      System.out.println(new String(createResult));
      System.out.println(" ############# Trajectory created ############## ");
      return true;
    } catch(Exception e) {
      System.out.println(" ############# ERROR ############## ");
      e.printStackTrace();
      System.out.println(" ############# ERROR ############## ");
    }

    return false;
  }
}
