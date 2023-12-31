from scripts.vote_2022_11_10 import start_vote
from utils.test.tx_tracing_helpers import *
from utils.test.event_validators.lido import validate_oracle_allowed_beacon_balance_increase_limit

ORACLE_ADDRESS = '0x442af784A788A5bd6F42A01Ebe9F287a871243fb'
ALLOWED_BEACON_BALANCE_INCREASE_LIMIT = 1750

def test_vote(
    helpers,
    bypass_events_decoding,
    vote_id_from_env,
    accounts,
    ldo_holder,
    oracle,
    dao_voting
):
    assert oracle.address == ORACLE_ADDRESS, "invalid oracle address"

    limit_before = oracle.getAllowedBeaconBalanceAnnualRelativeIncrease()
    assert limit_before == 1000, "incorrect current limit"

    # START VOTE
    vote_id: int = vote_id_from_env or start_vote({"from": ldo_holder}, silent=True)[0]

    tx: TransactionReceipt = helpers.execute_vote(
        vote_id=vote_id, accounts=accounts, dao_voting=dao_voting, skip_time=3 * 60 * 60 * 24
    )

    limit_after = oracle.getAllowedBeaconBalanceAnnualRelativeIncrease()
    assert limit_after == ALLOWED_BEACON_BALANCE_INCREASE_LIMIT, "incorrect limit after upgrade"

    # Validating events
    display_voting_events(tx)

    # Validate vote events
    if not bypass_events_decoding:
        assert count_vote_items_by_events(tx, dao_voting) == 1, "Incorrect voting items count"

    evs = group_voting_events(tx)

    validate_oracle_allowed_beacon_balance_increase_limit(evs[0], ALLOWED_BEACON_BALANCE_INCREASE_LIMIT)
