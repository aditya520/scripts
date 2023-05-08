import time
import os

from brownie import interface, accounts
from utils.shapella_upgrade import get_tx_params
from utils.config import (
    prompt_bool,
    get_deployer_account,
    lido_dao_template_address,
    lido_dao_lido_locator_implementation,
    contracts,
)


def main():

    deployer = get_deployer_account() if "DEPLOYER" in os.environ else accounts.at("0x2A78076BF797dAC2D25c9568F79b61aFE565B88C", force=True)

    assert interface.OssifiableProxy(contracts.lido_locator).proxy__getAdmin() == deployer

    print(f"=== Upgrade lido locator implementation to {lido_dao_lido_locator_implementation} ===")
    print(f"=== Change lido locator proxy admin to {lido_dao_template_address} ===")
    print(f"=== Deployer: {deployer} ===")

    print("Does it look good? [yes/no]")
    resume = prompt_bool()
    while resume is None:
        resume = prompt_bool()

    if not resume:
        print("Exit without running.")
        return False

    interface.OssifiableProxy(contracts.lido_locator).proxy__upgradeTo(
        lido_dao_lido_locator_implementation, get_tx_params(deployer)
    )

    interface.OssifiableProxy(contracts.lido_locator).proxy__changeAdmin(
        lido_dao_template_address, get_tx_params(deployer)
    )

    time.sleep(5)  # hack for waiting thread #2.
