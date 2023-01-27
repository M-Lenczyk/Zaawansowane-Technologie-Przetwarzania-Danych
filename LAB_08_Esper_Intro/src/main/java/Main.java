import java.io.IOException;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.runtime.client.EPRuntime;
import com.espertech.esper.runtime.client.EPRuntimeProvider;
import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

public class Main {
    public static void main(String[] args) throws IOException {
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);

        EPDeployment deployment = compileAndDeploy(epRuntime,
                "select istream data, kursOtwarcia - min(kursOtwarcia) as roznica, spolka " +
                        "from KursAkcji(spolka='Oracle').win:length(2) " +
                        "having kursOtwarcia > MIN(kursOtwarcia) ");

        ProstyListener prostyListener = new ProstyListener();
        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }

        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }

    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();
        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }
        return deployment;
    }
}

/*
//QUERIES
//zad24

"select irstream spolka as X, kursOtwarcia as Y " +
"from KursAkcji.win:length(3) " +
"where spolka = 'Oracle' "

//zad25

"select irstream data, kursOtwarcia, spolka " +
"from KursAkcji.win:length(3) " +
"where spolka = 'Oracle' "

//zad26

"select irstream data, kursOtwarcia, spolka " +
"from KursAkcji(spolka='Oracle').win:length(3) "

//zad27

"select istream data, kursOtwarcia, spolka " +
"from KursAkcji(spolka='Oracle').win:length(3) "

//zad28

"select istream data, max(kursOtwarcia), spolka " +
"from KursAkcji(spolka='Oracle').win:length(5) "

//zad29

"select istream data, kursOtwarcia - max(kursOtwarcia) as roznica, spolka " +
"from KursAkcji(spolka='Oracle').win:length(5) "

//zad30

"select istream data, kursOtwarcia - min(kursOtwarcia) as roznica, spolka " +
"from KursAkcji(spolka='Oracle').win:length(2) " +
"having kursOtwarcia > MIN(kursOtwarcia) "

*/