package connection;

import logic.Wallet;
import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.Network;

public class Bloc {
  private static CryptoBridge bridge = new CryptoBridge();

  public void connect() throws Exception {
    bridge.connect();
  }

  public Wallet[] queryAllWallets() throws Exception {
    byte[] result = null;

    // create a gateway connection
    try (Gateway gateway = bridge.getBuilder().connect()) {

      System.out.println(" Processing query \"QueryAllWallets\"");
      System.out.println(gateway);

      // get the network and contract
      System.out.println(bridge.channel);
      Network network = gateway.getNetwork(bridge.channel);
      System.out.println("Network created with channel " + bridge.channel);
      Contract contract = network.getContract(bridge.contract);
      System.out.println("Contract obtained " + bridge.contract);

      result = contract.evaluateTransaction("QueryAllWallets");
      System.out.println(new String(result));

    }catch(Exception e) {
      System.out.println(" ############# ERROR ############## ");
      e.printStackTrace();
      System.out.println(" ############# ERROR ############## ");
    }
    return new Wallet[]{};
  }
}
