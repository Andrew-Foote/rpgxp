from _pytest.fixtures import Parser
import golden

def pytest_addoption(parser: Parser):
	golden.add_options(parser)
