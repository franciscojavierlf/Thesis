package connection;

import org.hyperledger.fabric.gateway.*;
import org.hyperledger.fabric.sdk.Enrollment;
import org.hyperledger.fabric.sdk.User;
import org.hyperledger.fabric.sdk.security.CryptoSuite;
import org.hyperledger.fabric.sdk.security.CryptoSuiteFactory;
import org.hyperledger.fabric_ca.sdk.EnrollmentRequest;
import org.hyperledger.fabric_ca.sdk.HFCAClient;
import org.hyperledger.fabric_ca.sdk.RegistrationRequest;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.PrivateKey;
import java.util.Properties;
import java.util.Set;

public final class CryptoBridge {
  public static String connection;
  public static String user;
  public static String channel;
  public static String contract;
  public static String pemFile;
  public static String url;
  public static String asLocalhost = "";

  private Gateway.Builder builder;

  static {
    System.setProperty("org.hyperledger.fabric.sdk.service_discovery.as_localhost", asLocalhost);
  }

  public Gateway.Builder getBuilder() {
    return builder;
  }

  private static void init() {
    System.out.println( "Setting up blockchain explorer " );
    connection = Configuration.getInstance().getProperty(Configuration.CONNECTION);
    user = Configuration.getInstance().getProperty(Configuration.USER);
    channel = Configuration.getInstance().getProperty(Configuration.CHANNEL);
    contract = Configuration.getInstance().getProperty(Configuration.CONTRACT);
    pemFile = Configuration.getInstance().getProperty(Configuration.PEM_FILE);
    url = Configuration.getInstance().getProperty(Configuration.URL);
    asLocalhost = Configuration.getInstance().getProperty(Configuration.AS_LOCALHOST);


    System.out.println( " CONNECTION   : " + connection);
    System.out.println( " USER         : " + user);
    System.out.println( " CHANNEL      : " + channel);
    System.out.println( " CONTRACT     : " + contract);
    System.out.println( " PEM_FILE     : " + pemFile);
    System.out.println( " URL          : " + url);
    System.out.println( " AS_LOCALHOST : " + asLocalhost);
  }

  public void connect() throws Exception {
    if (connection == null)
      init();

    // Enroll admin
    enrollAdmin();
    // Wait for 10 seconds
    try {
      Thread.sleep(10000);
      System.out.println( " =========== > Finished enrollment .... wait for final settings " );
    } catch (InterruptedException e1) {
      // TODO Auto-generated catch block
      e1.printStackTrace();
    }
    // Register User
    registerUser();
    // Wait for 10 seconds
    try {
      Thread.sleep(10000);
      System.out.println( " =========== > Finished registering user .... wait for final settings " );
    } catch (InterruptedException e1) {
      // TODO Auto-generated catch block
      e1.printStackTrace();
    }

    // Setting REST API for blockchain explorer
    //myBCexplorer = new RestApiBc(connection, USER, CHANNEL, CONTRACT);
    //myBCexplorer.start();

    // Load a file system based wallet for managing identities.
    Path walletPath = Paths.get("wallet");
    Wallet wallet = Wallets.newFileSystemWallet(walletPath);

    if (wallet.get(user) == null) {
      System.out.printf("\"%s\" not registered", user);
      return;
    }

    // load a CCP
    Path networkConfigPath = Paths.get("src/", connection);
    //System.out.println(networkConfigPath.toFile().exists());

    builder = Gateway.createBuilder();
    builder.identity(wallet, user).networkConfig(networkConfigPath).discovery(false);
    System.out.println(" Finished connection to blockchain ... wait few seconds ");

    System.out.println( "Setting up blockchain explorer done!" );
  }

  public void enrollAdmin() throws Exception {
    // Create a CA client for interacting with the CA.
    Properties props = new Properties();
    props.put("pemFile", pemFile);
    props.put("allowAllHostNames", "true");
    HFCAClient caClient = HFCAClient.createNewInstance(url, props);
    CryptoSuite cryptoSuite = CryptoSuiteFactory.getDefault().getCryptoSuite();
    caClient.setCryptoSuite(cryptoSuite);

    // Create a wallet for managing identities
    Wallet wallet = Wallets.newFileSystemWallet(Paths.get("wallet"));

    // Check to see if we've already enrolled the admin user.
    if (wallet.get("admin") != null) {
      System.out.println("An identity for the admin user \"admin\" already exists in the wallet");
      return;
    }

    // Enroll the admin user, and import the new identity into the wallet.
    final EnrollmentRequest enrollmentRequestTLS = new EnrollmentRequest();
    enrollmentRequestTLS.addHost("localhost");
    enrollmentRequestTLS.setProfile("tls");
    Enrollment enrollment = caClient.enroll("admin", "adminpw", enrollmentRequestTLS);
    Identity user = Identities.newX509Identity("Org1MSP", enrollment);
    //.createIdentity("Org1MSP", enrollment.getCert(), enrollment.getKey());
    wallet.put("admin", user);
    System.out.println("Successfully enrolled user \"admin\" and imported it into the wallet");
  }


  public static void registerUser() throws Exception {

    // Create a CA client for interacting with the CA.
    Properties props = new Properties();
    props.put("pemFile",pemFile);
    //"../../energy-network/crypto-config/peerOrganizations/org1.government.com/ca/ca.org1.government.com-cert.pem");
    props.put("allowAllHostNames", "true");
    HFCAClient caClient = HFCAClient.createNewInstance(url, props);
    CryptoSuite cryptoSuite = CryptoSuiteFactory.getDefault().getCryptoSuite();
    caClient.setCryptoSuite(cryptoSuite);

    // Create a wallet for managing identities
    Wallet wallet = Wallets.newFileSystemWallet(Paths.get("wallet"));

    // Check to see if we've already enrolled the user.
    if (wallet.get(user) != null) {
      System.out.println("An identity for the user " + user + " already exists in the wallet");
      return;
    }

    X509Identity adminIdentity = (X509Identity)wallet.get("admin");
    if (adminIdentity == null) {
      System.out.println("\"admin\" needs to be enrolled and added to the wallet first");
      return;
    }
    User admin = new User() {
      @Override
      public String getName() {
        return "admin";
      }

      @Override
      public Set<String> getRoles() {
        return null;
      }

      @Override
      public String getAccount() {
        return null;
      }

      @Override
      public String getAffiliation() {
        return "org1.department1";
      }

      @Override
      public Enrollment getEnrollment() {
        return new Enrollment() {

          @Override
          public PrivateKey getKey() {
            return adminIdentity.getPrivateKey();
          }

          @Override
          public String getCert() {
            return Identities.toPemString(adminIdentity.getCertificate());
          }
        };
      }

      @Override
      public String getMspId() {
        return "Org1MSP";
      }

    };

    // Register the user, enroll the user, and import the new identity into the wallet.
    RegistrationRequest registrationRequest = new RegistrationRequest(user);
    registrationRequest.setAffiliation("org1.department1");
    registrationRequest.setEnrollmentID(user);
    String enrollmentSecret = caClient.register(registrationRequest, admin);
    Enrollment enrollment = caClient.enroll(user, enrollmentSecret);
    Identity identityUser = Identities.newX509Identity("Org1MSP", enrollment);
    // Identity user = Identities.newX509Identity("Org1MSP", adminIdentity.getCertificate(), adminIdentity.getPrivateKey());
    //Identity user = Identity.createIdentity("Org1MSP", enrollment.getCert(), enrollment.getKey());
    wallet.put(user, identityUser);
    System.out.println("Successfully enrolled user " + user + " and imported it into the wallet");
  }
}
