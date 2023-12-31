import time

from brownie import ShapellaUpgradeTemplate
from utils.config import (
    get_deployer_account,
    DEPLOYER_EOA,
)

# noinspection PyUnresolvedReferences
from utils.brownie_prelude import *


def main():
    deployer = get_deployer_account()
    assert deployer == DEPLOYER_EOA, "Need to set DEPLOYER to the DEPLOYER_EOA"

    template = ShapellaUpgradeTemplate.deploy({"from": deployer})
    print(f"Shapella upgrade template is deployed at {template}")

    ShapellaUpgradeTemplate.publish_source(template)

    time.sleep(5)  # hack for waiting thread #2.
