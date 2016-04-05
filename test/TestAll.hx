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
		
		trace("\n\n\nTests ported from js-uri, http://web.archive.org/web/20150518202232/https://skew.org/uri/uri_tests.html, plus some extra ones.\n\n" +
			  "\n\nNOTE: Should pass around 138/193 of the skew tests (see warning at the end of log)." +
			  "\nSee http://web.archive.org/web/20150518202232/https://skew.org/uri/uri_tests.html " +
			  "\nfor tests run with various implementations.\n");

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