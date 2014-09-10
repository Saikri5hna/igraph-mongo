import com.mongodb.BasicDBObject;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.DBCursor;
import com.mongodb.MongoClient;
import java.net.UnknownHostException;


public class igraph {

		public static void main(String[] args) throws UnknownHostException {

			try {
				
			MongoClient mongoClient = new MongoClient();
			
			DB db = mongoClient.getDB( "Accern" );
			
			DBCollection coll = db.getCollection("garbageForIgraph");
			
			BasicDBObject doc1 = new BasicDBObject("article_id", 0001)
	        .append("organizations", "org1")
	        .append("events", "event2, event3")
	        .append("volume", 100);
			
			BasicDBObject doc2 = new BasicDBObject("article_id", 0002)
	        .append("organizations", "org2, org3")
	        .append("events", "event1, event2")
	        .append("volume", 200);
			
			BasicDBObject doc3 = new BasicDBObject("article_id", 0003)
	        .append("organizations", "org1, org2, org3")
	        .append("events", "event3")
	        .append("volume", 50);

			coll.insert(doc1);
			coll.insert(doc2);
			coll.insert(doc3);
			

			DBCursor cursor = coll.find();
			try {
			    while (cursor.hasNext()) {
			        System.out.println(cursor.next());
			    }
			} finally {
			    cursor.close();
			    mongoClient.close();
				}
			}catch (UnknownHostException e) {
        	e.printStackTrace();
		} 
			}
		}
		

