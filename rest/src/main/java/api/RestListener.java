package api;

import com.google.gson.Gson;
import connection.Bloc;
import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.Network;
import spark.Spark;

public final class RestListener {
  public final Bloc bloc;

  public RestListener() {
    bloc = new Bloc();
  }

  public void start() throws Exception {
    // Starts the connection
    bloc.connect();

    // For testing
    Spark.get("/hello", (req, res) -> "Hello World!");

    // Query all wallets
    Spark.get("/wallets", (req, res) -> bloc.queryAllWallets());

    // Gets a single wallet
    Spark.get("/wallets/:walletId", (req, res) -> {
      String walletId = req.params(":walletId");
      return bloc.queryWallet(walletId);
    });

    // Trajectories from a wallet
    Spark.get("/wallets/:walletId/trajectories", (req, res) -> {
      String walletId = req.params(":walletId");
      return bloc.queryTrajectories(walletId);
    });

    // Creates a new trajectory
    Spark.post("/addTrajectory", (req, res) -> bloc.addTrajectory(req.body()));


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
