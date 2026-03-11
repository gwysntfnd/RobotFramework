#Resource/App.resource
*** Settings ***
Library      SeleniumLibrary
Variables    ../Variables/loginpage.py
Variables    ../Variables/common.py
Variables    ../Variables/customers.py
Library      ../Libraries/CommonLibrary.py

*** Variables ***
${TEST_URL}             https://marmelab.com/react-admin-demo
@{sales_submenu}        Orders    Invoices
@{catalog_submenu}      Posters    Categories
@{customers_submenu}    Customers    Segments
&{MENU}                 Sales=${sales_submenu}    Catalog=${catalog_submenu}    Customers=${customers_submenu}
@{USERS}
@{CUSTOMER_LOCATORS}
    ...    ${cust_txt_first_name}    ${cust_txt_last_name}    ${cust_txt_email}
    ...    ${cust_txt_birthday}      ${cust_txt_address}      ${cust_txt_city}
    ...    ${cust_txt_stateAbbr}     ${cust_txt_zipcode}      ${cust_txt_password}
    ...    ${cust_txt_confirm_password}

*** Keywords ***

Launch Browser
    [Arguments]    ${url}=${TEST_URL}
    Open Browser    ${url}    chrome    options=add_argument("--start-maximized")
    Wait Until Element Is Visible    ${login_txt_username}

Login User
    [Arguments]    ${username}=demo    ${password}=demo
    Input Text    ${login_txt_username}    ${username}
    Input Text    ${login_txt_password}    ${password}
    Capture Page Screenshot
    Click Button    ${login_btn_submit}
    Wait Until Element Is Visible    ${main_content}

Get Parent Menu
    [Arguments]    ${sub_menu}
    FOR    ${key}    IN    @{MENU.keys()}
        Return From Keyword If    "${sub_menu}" in ${MENU['${key}']}    //li[descendant::p[text()="${key}"]]
    END
    RETURN    ${None}

Navigate
    [Arguments]    ${sub_menu}
    ${sub_menu_loc}    Set Variable    //a[descendant::p[text()="${sub_menu}"]]
    ${status}    Run Keyword And Return Status    Element Should Be Visible    ${sub_menu_loc}
    IF    not ${status}
        ${parent_menu}    Get Parent Menu    ${sub_menu}
        Click Element    ${parent_menu}
        Wait Until Element Is Visible    ${sub_menu_loc}
    END
    Click Element    ${sub_menu_loc}
    Wait Until Element Is Visible    //h6[//span[text()="${sub_menu}"]]
    Run Keyword If    "${sub_menu}" == "Customers"    Sleep    2s