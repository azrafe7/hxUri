package;

import hxUri.TestParams;
import hxUri.TestParse;
import hxUri.TestResolve;
import hxUri.TestToString;
import hxUri.Uri;
import utest.ui.text.PrintReport;

import utest.Runner;
import utest.ui.Report;

class TestAll {
	static public function main():Void {
		
		var runner = new Runner();
		
		runner.addCase(new TestParams());
		runner.addCase(new TestParse());
		runner.addCase(new TestToString());
		runner.addCase(new TestResolve());
		
		new PrintReport(runner);
		runner.run();
		
	#if flash
		flash.system.System.exit(1);
	#end
	}
}