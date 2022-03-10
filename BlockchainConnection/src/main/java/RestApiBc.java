import java.nio.file.Path;
import java.nio.file.Paths;

import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.Network;
import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric.gateway.Wallets;
import com.google.gson.Gson;
import spark.Spark;

public class RestApiBc {
  String CONNECTION = "";
  String USER = "";
  String CHANNEL = "";
  String CONTRACT = "";

  public RestApiBc(String connection, String user, String channel, String contract) {
    this.CONNECTION = connection;
    this.USER       = user;
    this.CHANNEL    = channel;
    this.CONTRACT   = contract;
  }

  public void start() throws Exception {
    Gson gson = new Gson();


    // Load a file system based wallet for managing identities.
    Path walletPath = Paths.get("wallet");
    Wallet wallet = Wallets.newFileSystemWallet(walletPath);

    if (wallet.get(USER) == null) {
      System.out.printf("\"%s\" not registered", USER);
      return;
    }

    // load a CCP
    Path networkConfigPath = Paths.get("src/", CONNECTION);
    //System.out.println(networkConfigPath.toFile().exists());

    Gateway.Builder builder = Gateway.createBuilder();
    builder.identity(wallet, USER).networkConfig(networkConfigPath).discovery(false);

    System.out.println(" Finished connection to blockchain ... wait few seconds ");

    // ###################
    Spark.get("/query/:id", (req, res) -> {

      String id = req.params(":id");
      byte[] result = null;

      // create a gateway connection
      try (Gateway gateway = builder.connect()) {

        System.out.println(" Processing query request with id : " + id);

        // get the network and contract
        Network network = gateway.getNetwork(CHANNEL);
        Contract contract = network.getContract(CONTRACT);

        result = contract.evaluateTransaction("QueryCar",id);
        System.out.println(new String(result));

      }catch(Exception e) {
        System.out.println(" ############# ERROR ############## ");
        e.printStackTrace();
        System.out.println(" ############# ERROR ############## ");
      }

      return result;

    });


    // ###################
    Spark.get("/history/:id", (req, res) -> {

      String id = req.params(":id");
      byte[] result = null;

      // create a gateway connection
      try (Gateway gateway = builder.connect()) {

        System.out.println(" Processing history request with id : " + id);

        // get the network and contract
        Network network = gateway.getNetwork(CHANNEL);
        Contract contract = network.getContract(CONTRACT);

        result = contract.evaluateTransaction("GetHistoryCar",id);
        System.out.println(new String(result));

      }catch(Exception e) {
        System.out.println(" ############# ERROR ############## ");
        e.printStackTrace();
        System.out.println(" ############# ERROR ############## ");
      }

      return result; //gson.toJson(myData);

    });
    /*
    Spark.post("/createCar/:id", (req, res) -> {

      Fabcar myData = gson.fromJson(req.body(), Fabcar.class);
      String id = req.params(":id");

      // create a gateway connection
      try (Gateway gateway = builder.connect()) {

        System.out.println(" Processing createCar request  with id : " + id);

        // get the network and contract
        Network network = gateway.getNetwork(CHANNEL);
        Contract contract = network.getContract(CONTRACT);

        // Transaction
        byte[] createResult = contract.createTransaction("CreateCar")
          .submit(id, String.valueOf(myData.getMake()),String.valueOf(myData.getModel()),String.valueOf(myData.getColor()),String.valueOf(myData.getOwner()));

        System.out.println(" ############# Result ############## ");
        System.out.println(new String(createResult));

        System.out.println(" ############# Car created ############## ");

      }catch(Exception e) {
        System.out.println(" ############# ERROR ############## ");
        e.printStackTrace();
        System.out.println(" ############# ERROR ############## ");
      }

      return "";
    });

    Spark.post("/changeCarOwner/:id", (req, res) -> {

      NewOwner myData = gson.fromJson(req.body(), NewOwner.class);
      String id = req.params(":id");

      // create a gateway connection
      try (Gateway gateway = builder.connect()) {

        System.out.println(" Processing changeCarOwner request  with id : " + id);

        // get the network and contract
        Network network = gateway.getNetwork(CHANNEL);
        Contract contract = network.getContract(CONTRACT);

        // Transaction
        byte[] createResult = contract.createTransaction("ChangeCarOwner")
          .submit(id, String.valueOf(myData.getOwner()));

        System.out.println(" ############# Result ############## ");
        System.out.println(new String(createResult));

        System.out.println(" ############# Change done ############## ");

      }catch(Exception e) {
        System.out.println(" ############# ERROR ############## ");
        e.printStackTrace();
        System.out.println(" ############# ERROR ############## ");
      }

      return "";
    });
    */

    // Wait for 10 seconds
    try {
      Thread.sleep(10000);
    } catch (InterruptedException e1) {
      // TODO Auto-generated catch block
      e1.printStackTrace();
    }

    System.out.println(" Rest API Up and ready to process calls  ");

  }
}