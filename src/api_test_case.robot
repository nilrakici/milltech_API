*** Settings ***
Library      RequestsLibrary
Library      Collections
Library      JSONLibrary

*** Variables ***
${base_url}   https://gorest.co.in
${session}
${response}
${status}
${body}
${json_response}
${total_data}
${pages_data}
${page_data}
${limit_data}

*** Keywords ***
I Set GET user service API endpoint
    create session         mysession      ${base_url}
    set global variable    ${session}     mysession

I Send a GET request
    ${response}=    get on session     ${session}  /public/v1/users
    ${status}=      convert to string  ${response.status_code}
    ${body}=        convert to string  ${response.content}

    ${json_response}=   set variable                      ${response.json()}
    ${total_data}=      jsonlibrary.get value from json   ${json_response}   meta.pagination.total
    ${pages_data}=      jsonlibrary.get value from json   ${json_response}   meta.pagination.pages
    ${page_data}=       jsonlibrary.get value from json   ${json_response}   meta.pagination.page
    ${limit_data}=      jsonlibrary.get value from json   ${json_response}   meta.pagination.limit

    set global variable    ${json_response}
    set global variable    ${total_data}
    set global variable    ${pages_data}
    set global variable    ${page_data}
    set global variable    ${limit_data}
    set global variable    ${response}
    set global variable    ${status}
    set global variable    ${body}

Response should be valid
  should not be equal    ${json_response}    NULL
  should be equal        ${status}           200
  should not be equal    ${body}             NULL
  should not be equal    ${total_data}       NULL
  should not be equal    ${pages_data}       NULL
  should not be equal    ${page_data}        NULL
  should not be equal    ${limit_data}       NULL

*** Test Cases ***
Scenario: API Test
    Given I Set GET user service API endpoint
    When I Send a GET request
    Then Response should be valid




