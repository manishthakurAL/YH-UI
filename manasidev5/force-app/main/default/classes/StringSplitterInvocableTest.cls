@isTest
public class StringSplitterInvocableTest {

    @isTest
    static void testSplitString() {
        StringSplitterInvocable.Input testInput = new StringSplitterInvocable.Input();
        testInput.inputString = '100,200,300';

        List<StringSplitterInvocable.Input> inputs = new List<StringSplitterInvocable.Input>{ testInput };

        List<StringSplitterInvocable.Output> results = StringSplitterInvocable.splitString(inputs);

        System.assertEquals(1, results.size(), 'There should be one output object.');
        System.assert(results[0].outputCollection != null, 'The output collection should not be null.');
        System.assertEquals(3, results[0].outputCollection.size(), 'The output collection should have three elements.');
        System.assertEquals('100', results[0].outputCollection[0], 'The first element should be 100.');
        System.assertEquals('200', results[0].outputCollection[1], 'The second element should be 200.');
        System.assertEquals('300', results[0].outputCollection[2], 'The third element should be 300.');
    }

    @isTest
    static void testEmptyInputString() {
        StringSplitterInvocable.Input testInput = new StringSplitterInvocable.Input();
        testInput.inputString = '';

        List<StringSplitterInvocable.Input> inputs = new List<StringSplitterInvocable.Input>{ testInput };

        List<StringSplitterInvocable.Output> results = StringSplitterInvocable.splitString(inputs);

        System.assertEquals(1, results.size(), 'There should be one output object.');
        System.assert(results[0].outputCollection != null, 'The output collection should not be null.');
        System.assertEquals(0, results[0].outputCollection.size(), 'The output collection should be empty.');
    }

    @isTest
    static void testNullInputString() {
        StringSplitterInvocable.Input testInput = new StringSplitterInvocable.Input();
        testInput.inputString = null;

        List<StringSplitterInvocable.Input> inputs = new List<StringSplitterInvocable.Input>{ testInput };

        List<StringSplitterInvocable.Output> results = StringSplitterInvocable.splitString(inputs);

        System.assertEquals(1, results.size(), 'There should be one output object.');
        System.assert(results[0].outputCollection != null, 'The output collection should not be null.');
        System.assertEquals(0, results[0].outputCollection.size(), 'The output collection should be empty.');
    }
}