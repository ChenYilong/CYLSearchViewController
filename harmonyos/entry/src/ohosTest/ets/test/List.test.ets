import cylSearchCoreTest from './CYLSearchCore.test';
import cylSearchUITest from './CYLSearchUI.test';
import cylSearchQMUIPortTest from './CYLSearchQMUIPort.test';
import cylSearchMergeTest from './CYLSearchMerge.test';

export default function testsuite() {
  cylSearchCoreTest();
  cylSearchUITest();
  cylSearchQMUIPortTest();
  cylSearchMergeTest();
}
