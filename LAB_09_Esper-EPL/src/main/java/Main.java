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
                "select istream data, spolka, obrot " +
                        "from KursAkcji(market='NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
                        "order by obrot desc " +
                        "limit 1 offset 2");

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
//Gdzie reszta zdarzeń ISTREAM?
//Gdzie reszta zdarzeń RSTREAM?
//ODP: Są starsze niż 7 dni więc ich nie wyswietliło

/*
//QUERIES
//zad2a

"select irstream data, kursZamkniecia, max(kursZamkniecia) " +
"from KursAkcji(spolka = 'Oracle').win:ext_timed(data.getTime(), 7 days) "

//zad2b

"select irstream data, kursZamkniecia, max(kursZamkniecia)" +
"from KursAkcji(spolka = 'Oracle').win:ext_timed_batch(data.getTime(), 7 days) "

//zad5
"select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
"from KursAkcji.win:ext_timed_batch(data.getTime(), 1 day) "

//zad6

"select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
"from KursAkcji(spolka in ('IBM', 'Honda', 'Microsoft')).win:ext_timed_batch(data.getTime(), 1 day)"

//zad7a

"select istream data, spolka, kursOtwarcia, kursZamkniecia " +
"from KursAkcji(kursZamkniecia > kursOtwarcia).win:length(1)"

//zad7b

------

//zad8

"select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
"from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed(data.getTime(), 7 days)"

//zad9

"select istream data, spolka, kursZamkniecia " +
"from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed_batch(data.getTime(), 1 day) " +
"having kursZamkniecia = max(kursZamkniecia)"

//zad10

"select istream kursZamkniecia as maksimum " +
"from KursAkcji.win:ext_timed_batch(data.getTime(), 7 days) " +
"having kursZamkniecia = max(kursZamkniecia)"

//zad11

"select istream c.kursZamkniecia as kursCoc, p.data, p.kursZamkniecia as kursPep " +
"from KursAkcji(spolka='CocaCola').win:length(1) as c " +
"join KursAkcji(spolka='PepsiCo').win:length(1) as p on c.data = p.data " +
"where p.kursZamkniecia > c.kursZamkniecia"

//zad12

"select istream k.data, k.kursZamkniecia as kursBiezacy, k.spolka, k.kursZamkniecia - x.kursZamkniecia as roznica " +
"from KursAkcji(spolka in ('CocaCola', 'PepsiCo')).win:length(1) as k " +
"join KursAkcji(spolka in ('CocaCola', 'PepsiCo')).std:firstunique(spolka) as x on k.spolka = x.spolka"

//zad13

"select istream k.data, k.kursZamkniecia as kursBiezacy, k.spolka, k.kursZamkniecia - x.kursZamkniecia as roznica " +
"from KursAkcji.win:length(1) as k " +
"join KursAkcji.std:firstunique(spolka) as x on k.spolka = x.spolka " +
"where k.kursZamkniecia > x.kursZamkniecia"

//zad14

"select istream k.data as dataB, x.data as dataA, k.spolka, x.kursOtwarcia as kursA, k.kursOtwarcia as kursB " +
"from KursAkcji.win:ext_timed(data.getTime(), 7 days) as k " +
"join KursAkcji.win:ext_timed(data.getTime(), 7 days) as x on k.spolka = x.spolka " +
"where k.kursOtwarcia - x.kursOtwarcia > 3"

//zad15

"select istream data, spolka, obrot " +
"from KursAkcji(market='NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
"order by obrot desc " +
"limit 3"

//zad16

"select istream data, spolka, obrot " +
"from KursAkcji(market='NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
"order by obrot desc " +
"limit 1 offset 2"

*/