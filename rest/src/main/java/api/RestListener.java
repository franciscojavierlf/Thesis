package api;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import connection.Bloc;
import spark.Spark;

public final class RestListener {
  public final Bloc bloc;

  public RestListener() {
    bloc = new Bloc();
  }

  public void start() throws Exception {
    // Starts the connection
    bloc.connect();

    // Query all wallets
    Spark.get("/wallets", (req, res) -> {
      try {
        JsonArray json = bloc.queryAllWallets();
        return json;
      } catch(Exception ex) {
        res.status(412);
        return "{error:" + ex + "}";
      }
    });

    // Gets a single wallet
    Spark.get("/wallets/:walletId", (req, res) -> {
      String walletId = req.params(":walletId");
      try {
        JsonObject json = bloc.queryWallet(walletId);
        return json;
      } catch(Exception ex) {
        res.status(412);
        return "{error:" + ex + "}";
      }
    });

    // Trajectories from a wallet
    Spark.get("/wallets/:walletId/trajectories", (req, res) -> {
      String walletId = req.params(":walletId");
      try {
        JsonArray json = bloc.queryTrajectories(walletId);
        return json;
      } catch(Exception ex) {
        res.status(412);
        return "{error:" + ex + "}";
      }
    });

    // Creates a new trajectory
    Spark.post("/addTrajectory/:walletId", (req, res) -> {
      String walletId = req.params(":walletId");
      try {
        JsonObject json = bloc.addTrajectory(walletId, req.body());
        return json;
      } catch(Exception ex) {
        res.status(412);
        return "{error:" + ex + "}";
      }
    });

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
