import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

public class Configuration {

  public static final String CONNECTION = "CONNECTION";
  public static final String USER = "USER";
  public static final String CHANNEL = "CHANNEL";
  public static final String CONTRACT = "CONTRACT";
  public static final String PEM_FILE = "PEM_FILE";
  public static final String URL = "URL";
  public static final String AS_LOCALHOST = "AS_LOCALHOST";


  private static Configuration instance;
  private static Properties properties = new Properties();

  private Configuration(){
    try {
      properties.load(new FileInputStream("src/bc_app.config"));
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  public static synchronized Configuration getInstance(){
    if(instance == null){
      instance = new Configuration();
    }

    return instance;
  }

  public String getProperty(String key){
    return properties.getProperty(key);
  }

  public String getProperty(String key, String defaultValue){
    return properties.getProperty(key, defaultValue);
  }

}