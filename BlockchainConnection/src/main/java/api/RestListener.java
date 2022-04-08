package api;

import connection.Bloc;
import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.Network;
import spark.Request;
import spark.Response;
import spark.Spark;

public final class RestListener {
  public final Bloc bloc;

  public RestListener() {
    bloc = new Bloc();
  }

  public void start() throws Exception {
    // Starts the connection
    bloc.connect();

    // Then listens
    Spark.get("/queryAllWallets", (req, res) -> bloc.queryAllWallets());

    Spark.get("/wallets/:walletId/trajectories", (req, res) -> {
      String walletId = req.params(":walletId");
      return bloc.getTrajectoriesFromWallet(walletId);
    });

    /*
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

     */
    // Wait for 10 seconds
    try {
      Thread.sleep(10000);
    } catch (InterruptedException e1) {
      // TODO Auto-generated catch block
      e1.printStackTrace();
    }

    System.out.println("Rest API up on port " + Spark.port());
  }
}
