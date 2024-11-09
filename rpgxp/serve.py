import runpy
import sys
from rpgxp import settings

def run() -> None:
    sys.argv[1:] = (
        '--directory', str(settings.site_root), '--bind', '127.0.0.1'
    )
    
    runpy.run_module('http.server', {'sys': sys}, '__main__')

if __name__ == '__main__':
    run()