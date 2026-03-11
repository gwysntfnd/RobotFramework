#Resource/Customer.resource
*** Settings ***
Resource     App.resource
Library      DateTime

*** Keywords ***

Open Create Modal
    Click Element    //a[text()="Create"]
    Wait Until Element Is Visible    //h6[descendant::span[text()="Create Customer"]]

Open Edit For Row
    [Arguments]    ${row_number}
    Navigate    Customers
    Wait Until Element Is Visible    ((//tbody//tr)[${row_number}]//td)[2]    timeout=15s
    Click Element    ((//tbody//tr)[${row_number}]//td)[2]
    Wait Until Element Is Visible    ${cust_txt_first_name}    timeout=15s

Clear And Type
    [Arguments]    ${locator}    ${value}
    Wait Until Element Is Visible    ${locator}
    Click Element    ${locator}
    Press Keys    ${locator}    CTRL+a    BACKSPACE
    Sleep    0.1s
    Input Text    ${locator}    ${value}

Clean Text
    [Arguments]    ${text}
    IF    "\\n" in """${text}"""
        ${text}    Evaluate    """${text}""".replace("\\n","")[1:]
    END
    Return From Keyword    ${text}

Format Birthday
    [Arguments]    ${date}
    ${formatted}    Evaluate    "/".join("${date}".split("-")[1:]+["${date}".split("-")[0]])
    RETURN    ${formatted}


Get Customer Row
    [Arguments]    ${user}
    Navigate    Customers
    ${web_elems}    Get WebElements    //tbody//tr

    FOR    ${i}    ${elem}    IN ENUMERATE    @{web_elems}
        ${row_index}    Set Variable    ${i + 1}
        ${name}    Get Text    ((//tbody//tr)[${row_index}]//td)[2]
        ${name}    Clean Text    ${name}
        Return From Keyword If    "${user['first_name']} ${user['last_name']}" == "${name}"    ${i+1}
    END
    RETURN    None

Get Table Headers
    ${header_elements}    Get WebElements    //thead//th
    ${header_texts}    Evaluate    [elem.text.strip() for elem in $header_elements]
    RETURN    ${header_texts}

Add Multiple Customers
    [Arguments]    @{users}

    FOR    ${user}    IN    @{users}
        Log To Console    \n--- Adding ${user['first_name']} ${user['last_name']} ---
        Navigate    Customers
        Open Create Modal

        ${values}=    Create List
        ...    ${user['first_name']}    
        ...    ${user['last_name']}     
        ...    ${user['email']}         
        ...    ${user['birthday']}      
        ...    ${user["address"]["street"]} ${user["address"]["suite"]}
        ...    ${user["address"]["city"]}  
        ...    ${user["address"]["stateAbbr"]} 
        ...    ${user["address"]["zipcode"]}  
        ...    ${user['password']}      
        ...    ${user['password']}

        FOR    ${i}    ${locator}    IN ENUMERATE    @{CUSTOMER_LOCATORS}
            ${value}=    Set Variable    ${values[${i}]}
            IF    '${locator}' == '${cust_txt_birthday}'
                Input Text    ${locator}    ${value}
            ELSE
                Clear And Type    ${locator}    ${value}
            END
        END

        Click Button  ${cust_btn_save}
        Wait Until Element Is Visible    //div[text()="Customer created"]
        Verify If Customer Is Added In The Table    ${user}
        Verify Customer Identity Details    ${user}
        Log To Console    --- Verified Successfully ${user['first_name']} ${user['last_name']} ---
    END

Update Multiple Customers
    [Arguments]    @{users}    ${start_row}=6
    ${row_number}    Set Variable    ${start_row}

    FOR    ${user}    IN    @{users}
        Log To Console    \n--- Updating row ${row_number} with ${user['first_name']} ${user['last_name']} ---
        Open Edit For Row    ${row_number}

        ${values}    Create List
        ...    ${user['first_name']}    
        ...    ${user['last_name']}     
        ...    ${user['email']}         
        ...    ${user['birthday']}      
        ...    ${user["address"]["street"]} ${user["address"]["suite"]}
        ...    ${user["address"]["city"]}  
        ...    ${user["address"]["stateAbbr"]} 
        ...    ${user["address"]["zipcode"]}  
        ...    ${user['password']}      
        ...    ${user['password']}

        FOR    ${i}    ${locator}    IN ENUMERATE    @{CUSTOMER_LOCATORS}
            ${value}=    Set Variable    ${values[${i}]}
            IF    '${locator}' == '${cust_txt_birthday}'
                Input Text    ${locator}    ${value}
            ELSE
                Clear And Type    ${locator}    ${value}
            END
        END

        Scroll Element Into View    ${cust_btn_save}
        Click Button    ${cust_btn_save}
        Wait Until Page Contains    Customer updated    timeout=20s
        Verify If Customer Is Added In The Table    ${user}
        Verify Customer Identity Details    ${user}
        Log To Console    --- Verified Successfully ${user['first_name']} ${user['last_name']} ---
        ${row_number}    Evaluate    ${row_number}+1
    END

Verify Customer Identity Details
    [Arguments]    ${user}
    Navigate    Customers
    ${user_row}    Get Customer Row    ${user}
    Wait Until Element Is Visible    ((//tbody//tr)[${user_row}]//td)[2]
    Click Element    ((//tbody//tr)[${user_row}]//td)[2]
    Wait Until Element Is Visible    ${cust_txt_first_name}

    ${locators}    Create List
    ...    ${cust_txt_first_name}    ${cust_txt_last_name}    ${cust_txt_email}
    ...    ${cust_txt_birthday}      ${cust_txt_address}      ${cust_txt_city}
    ...    ${cust_txt_stateAbbr}     ${cust_txt_zipcode}      ${cust_txt_password}
    ...    ${cust_txt_confirm_password}

    ${expected_values}    Create List
    ...    ${user['first_name']}    ${user['last_name']}    ${user['email']}
    ...    ${user['birthday']}
    ...    ${user["address"]["street"]} ${user["address"]["suite"]}
    ...    ${user["address"]["city"]}   ${user["address"]["stateAbbr"]}
    ...    ${user["address"]["zipcode"]}
    ...    ${user['password']}    ${user['password']}

    FOR    ${i}    ${locator}    IN ENUMERATE    @{locators}
        Mouse Over    ${locator}
        ${value_text}    Get Value    ${locator}
        IF    '${locator}' == '${cust_txt_birthday}'
            ${value_text}    Format Birthday    ${value_text}
        END
        Should Be Equal As Strings    ${expected_values[${i}]}    ${value_text}
    END

Verify Customer Identity Details At Row
    [Arguments]    ${row_number}    ${user}
    Open Edit For Row    ${row_number}

    ${locators}    Create List
    ...    ${cust_txt_first_name}    ${cust_txt_last_name}    ${cust_txt_email}
    ...    ${cust_txt_birthday}      ${cust_txt_address}      ${cust_txt_city}
    ...    ${cust_txt_stateAbbr}     ${cust_txt_zipcode}

    ${expected_values}    Create List
    ...    ${user['first_name']}    ${user['last_name']}    ${user['email']}
    ...    ${user['birthday']}
    ...    ${user["address"]["street"]} ${user["address"]["suite"]}
    ...    ${user["address"]["city"]}   ${user["address"]["stateAbbr"]}
    ...    ${user["address"]["zipcode"]}

    FOR    ${i}    ${locator}    IN ENUMERATE    @{locators}
        Mouse Over    ${locator}
        ${value_text}    Get Value    ${locator}
        IF    '${locator}' == '${cust_txt_birthday}'
            ${value_text}    Format Birthday    ${value_text}
        END
        Should Be Equal As Strings    ${expected_values[${i}]}    ${value_text}
    END

Verify If Customer Is Added In The Table
    [Arguments]    ${user}
    ${user_row}    Get Customer Row    ${user}
    Should Not Be Equal As Strings    None    ${user_row}



Log News Cell
    [Arguments]    ${row_num}    ${col_num}    ${header}

    ${has_check}    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    ((//tbody//tr)[${row_num}]//td)[${col_num}]//*[name()='svg'][contains(@data-testid,'Check')]

    ${result}    Set Variable If    ${has_check}    Yes    No

    Log To Console   ${header}: ${result}
    
Log Segments Cell
    [Arguments]    ${row_num}    ${col_num}    ${header}    ${cell}
    ${seg_elems}    Get WebElements
    ...    ((//tbody//tr)[${row_num}]//td)[${col_num}]//*[contains(@class,'MuiChip') or contains(@class,'chip') or contains(@class,'tag')]
    ${seg_count}    Get Length    ${seg_elems}
    ${seg_texts}    Run Keyword If    ${seg_count} > 0
    ...    Evaluate    ", ".join([e.text.strip() for e in $seg_elems if e.text.strip()])
    ...    ELSE    Evaluate    ", ".join([s.strip() for s in """${cell}""".split("\\n") if s.strip()])
    Run Keyword If    "${seg_texts}".strip() != ""
    ...    Log To Console    ${header}: ${seg_texts}

Log Table Data First Page
    Navigate    Customers
    Sleep    2s

    ${headers}    Get Table Headers
    ${row_elements}    Get WebElements    //tbody//tr
    ${row_count}    Get Length    ${row_elements}

    FOR    ${i}    IN RANGE    ${row_count}
        ${row_num}    Evaluate    ${i} + 1
        Log To Console     \n****** User ${row_num} ******

        ${cell_count}    Evaluate    len($headers)
        FOR    ${j}    IN RANGE    ${cell_count}
            ${col_num}    Evaluate    ${j} + 1
            ${header}    Evaluate    $headers[${j}]

            # Skip columns that should be hidden when empty
            ${is_skippable}    Evaluate
            ...    "${header}".strip().lower() in ["latest purchase", "segments"]

            ${raw_cell}    Get Text    ((//tbody//tr)[${row_num}]//td)[${col_num}]
            ${cell}    Clean Text    ${raw_cell}

            # Skip if header is empty
            IF    "${header}".strip() == ""    CONTINUE

            # Skip skippable columns when value is empty
            IF    ${is_skippable} and "${cell}".strip() == ""    CONTINUE

            # Handle News column: convert check/x icon to Yes/No
            ${header_lower}    Evaluate    "${header}".strip().lower()
            IF    "${header_lower}" == "news"
                ${news_elem}    Get WebElement    ((//tbody//tr)[${row_num}]//td)[${col_num}]
                ${has_check}    Run Keyword And Return Status
                ...    Element Should Contain    ${news_elem}    ✓
                IF    not ${has_check}
                    ${has_check}    Run Keyword And Return Status
                    ...    Page Should Contain Element
                    ...    ((//tbody//tr)[${row_num}]//td)[${col_num}]//*[contains(@class,"true") or contains(@class,"check") or contains(@data-testid,"true")]
                END
                ${cell}    Set Variable If    ${has_check}    Yes    No
                Log To Console     ${header}: ${cell}
                CONTINUE
            END

            # Handle Segments column: join multiple values with comma
            IF    "${header_lower}" == "segments"
                ${seg_elems}    Get WebElements
                ...    ((//tbody//tr)[${row_num}]//td)[${col_num}]//*[contains(@class,"chip") or contains(@class,"tag") or contains(@class,"MuiChip")]
                ${seg_count}    Get Length    ${seg_elems}
                IF    ${seg_count} > 0
                    ${seg_texts}    Evaluate
                    ...    ", ".join([e.text.strip() for e in $seg_elems if e.text.strip()])
                    Log To Console     ${header}: ${seg_texts}    
                ELSE
                    # Fallback: use raw cell text, replace newlines with comma
                    ${seg_texts}    Evaluate
                    ...    ", ".join([s.strip() for s in "${cell}".split("\\n") if s.strip()])
                    IF    "${seg_texts}" != ""
                        Log To Console    ${header}: ${seg_texts}
                    END
                END
                CONTINUE
            END

            # Default: print if not empty
            IF    "${cell}".strip() != ""
                Log To Console   ${header}: ${cell}
            END
        END
    END

Analyze User Spending
    [Arguments]    ${threshold}=3500
    Navigate    Customers
    Sleep    2s

    ${headers}    Get Table Headers

    # Find "Total Spent" column index (1-based)
    ${total_spent_col}    Evaluate
    ...    next((i+1 for i,h in enumerate($headers) if "spent" in h.lower() or "total" in h.lower()), None)

    ${name_col}    Set Variable    2

    ${row_elements}    Get WebElements    //tbody//tr
    ${row_count}    Get Length    ${row_elements}

    ${grand_total}    Set Variable    ${0}
    ${counter}    Set Variable    ${0}

    FOR    ${i}    IN RANGE    ${row_count}
        ${row_num}    Evaluate    ${i} + 1
        ${name}    Get Text    ((//tbody//tr)[${row_num}]//td)[${name_col}]
        ${name}    Clean Text    ${name}

        ${spent_raw}    Run Keyword If    $total_spent_col is not None
        ...    Get Text    ((//tbody//tr)[${row_num}]//td)[${total_spent_col}]
        ...    ELSE    Set Variable    $0

        ${spent_raw}    Set Variable If    "${spent_raw}" == ""    $0    ${spent_raw}

        ${spent_num}    Evaluate
        ...    float("${spent_raw}".replace("$","").replace(",","")) if "${spent_raw}".strip() else 0.0

        IF    ${spent_num} > 0
            ${counter}    Evaluate    ${counter} + 1
            ${grand_total}    Evaluate    ${grand_total} + ${spent_num}
            Log To Console   \n ${counter}. ${name}: ${spent_raw}
        END
    END

    ${grand_total_fmt}    Evaluate    f"{${grand_total}:,.2f}"
    ${threshold_fmt}    Evaluate    f"{${threshold}:,}"

    Log To Console    \n============================
    Log To Console    Total Customer Spending: \$${grand_total_fmt}
    Log To Console   ==============================

    IF    ${grand_total} < ${threshold}
    Log To Console   FAIL: Total spending (\$${grand_total_fmt}) is below minimum threshold (\$${threshold_fmt}) 
        Fail    Total spending ($${grand_total_fmt}) is below minimum threshold ($${threshold_fmt})
    ELSE
        Log To Console   PASS: Total spending (\$${grand_total_fmt}) meets minimum threshold (\$${threshold_fmt})
    END
