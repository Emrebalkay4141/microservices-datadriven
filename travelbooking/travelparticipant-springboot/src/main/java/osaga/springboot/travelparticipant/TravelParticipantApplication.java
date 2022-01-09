package osaga.springboot.travelparticipant;

import AQSaga.AQjmsSaga;
import AQSaga.AQjmsSagaMessageListener;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import java.nio.file.Path;
import java.nio.file.Paths;

import static java.lang.System.out;

@Configuration
@EnableAutoConfiguration
@ComponentScan
@SpringBootApplication
public class TravelParticipantApplication {

	public static void main(String[] args) throws Exception {
		System.setProperty("oracle.jdbc.fanEnabled", "false");
		new TravelParticipantApplication().participate();
	}

	public void participate() throws Exception {
		//Get all values...
		String password = PromptUtil.getValueFromPromptSecure("Enter password", null);
		Path path = Paths.get(System.getProperty("user.dir"));
		String parentOfCurrentWorkingDir = "" + path.getParent();
		String TNS_ADMIN = PromptUtil.getValueFromPrompt("Enter TNS_ADMIN (unzipped wallet location)", parentOfCurrentWorkingDir + "/" + "wallet");
		String jdbcUrl = "jdbc:oracle:thin:@sagadb2_tp?TNS_ADMIN=" + TNS_ADMIN;
		out.println("TravelParticipantApplication jdbcUrl:" + jdbcUrl);

		String participant = PromptUtil.getValueFromPrompt("Enter participant type (1) HotelJava, (2) CarJava, or (3) FlightJava", "1");
		if (participant.equalsIgnoreCase("2")) participant = "CarJava";
		else if (participant.equalsIgnoreCase("3")) participant = "FlightJava";
		else participant = "HotelJava";
		out.println("Adding listener for this saga participant:" + participant + "...");
		AQjmsSaga saga = new AQjmsSaga(jdbcUrl, "admin", password);
		TravelParticipantSagaMessageListener listener = new TravelParticipantSagaMessageListener();
		saga.setSagaMessageListener("ADMIN", participant, listener);

		while(true) Thread.sleep(1000 * 10);
	}

	public class TravelParticipantSagaMessageListener extends AQjmsSagaMessageListener {

		//in-memory
		int tickets = 2;

		@Override
		public String request(String sagaId, String payload) {
			System.out.println("request called sagaId = " + sagaId + ", payload = " + payload);
			System.out.println("Tickets remaining : " + --tickets);
			if(tickets >= 0)
				return "[{\"result\":\"success\"}]";
			else
				return "[{\"result\":\"failure\"}]";
		}

		@Override
		public void response(String sagaId, String payload) {
			System.out.println("response called sagaId = " + sagaId + ", payload = " + payload);
		}

		@Override
		public void beforeCommit(String sagaId) {
			out.println("Before Commit Called");
		}

		@Override
		public void afterCommit(String sagaId) {
			out.println("After Commit Called");
		}

		@Override
		public void beforeRollback(String sagaId) {
			out.println("Before Rollback Called");
			tickets++;
			System.out.println("Total Tickets : " + tickets);
		}

		@Override
		public void afterRollback(String sagaId) {
			out.println("After Rollback Called");
		}

	}

}