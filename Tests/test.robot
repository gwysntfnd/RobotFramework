#Tests/test.robot
*** Settings ***
Resource          ../Resource/App.resource
Resource          ../Resource/Customer.resource

Suite Setup       Suite Init
Suite Teardown    Capture Page Screenshot

*** Test Cases ***

TEST-1
    [Documentation]
    ...    TASK 1: Add the first 5 users from the API as new customers.
    ...    For each user: verify name, email, and all other details.
    ...    Then confirm each appears in the customers table.

    Add Multiple Customers    @{USERS}[0:5]

TEST-2
    [Documentation]
    ...    TASK 2: Use API users 6-10 (index 5-9) to overwrite table rows 6-10.
    ...    For each row: replace all fields, then verify name, email, and all details.

    Update Multiple Customers   @{USERS}[5:10]

TEST-3
    [Documentation]
    ...    TASK 3: Print every row on the first Customers page.
    ...    Format:
    ...      ****** User N ******
    ...      ColumnName: Value
    ...      (skip empty values)

    Log Table Data First Page

TEST-4
    [Documentation]
    ...    TASK 4: Print all users whose total spent > 0, sum totals,
    ...    and FAIL if the grand total is below $3,500.

    Analyze User Spending    threshold=3500

*** Keywords ***

Suite Init
    Launch Browser
    Login User
    ${users}    Get Users
    Set Suite Variable    ${USERS}    ${users}
