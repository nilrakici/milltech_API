*** Settings ***
Library      RequestsLibrary
Library      Collections
Library      JSONLibrary

*** Variables ***
${base_url}   http://api.zippopotam.us/
${session}
${response}
${wrong_status}
${body}
${json_response}
${post_code}
${country}
${country_abv}
${places}
${seperator}  /
${robot}
${states}
${len}
${longitude}
${latitude}
${place_name}
${state_abv}

*** Keywords ***
I am searching for a postcode
    create session         mysession      ${base_url}
    set global variable    ${session}     mysession

I make a valid request
    [Arguments]     ${code_request}    ${range}
    ${response}=    get on session     ${session}  ${code_request}${seperator}${range}

    ${json_response}=     set variable                      ${response.json()}
    ${post_code}=         jsonlibrary.get value from json   ${json_response}    'post code'
    ${country}=           jsonlibrary.get value from json   ${json_response}    'country'
    ${country_abv}=       jsonlibrary.get value from json   ${json_response}    'country abbreviation'
    ${places}=            jsonlibrary.get value from json   ${json_response}    'places'
    ${len}=               Get length                        ${places}[0]
    ${states}=            jsonlibrary.get value from json   ${json_response}    'places'[0:${len}].state
    ${place_name}=        jsonlibrary.get value from json   ${json_response}    'places'[0:${len}].'place name'
    ${longitude}=         jsonlibrary.get value from json   ${json_response}    'places'[0:${len}].longitude
    ${state_abv}=         jsonlibrary.get value from json   ${json_response}    'places'[0:${len}].'state abbreviation'
    ${latitude}=          jsonlibrary.get value from json   ${json_response}    'places'[0:${len}].latitude

    set global variable    ${json_response}
    set global variable    ${post_code}
    set global variable    ${country}
    set global variable    ${country_abv}
    set global variable    ${places}
    set global variable    ${states}
    set global variable    ${longitude}
    set global variable    ${place_name}
    set global variable    ${latitude}
    set global variable    ${state_abv}

the request contains the following fields and types
    ${type_post}=           Evaluate               type(($post_code)[0]).__name__
    should be equal         ${type_post}           str
    ${type_country}=        Evaluate               type(($country)[0]).__name__
    should be equal         ${type_country}        str
    ${type_country_abv}=    Evaluate               type(($country_abv)[0]).__name__
    should be equal         ${type_country_abv}    str
    ${type_places}=         Evaluate               type(($places)[0]).__name__
    should be equal         ${type_places}         list

the post code returned in the response matches the postcode I pass as a request parameter
    [Arguments]             ${code_request}               ${range}
    should be equal         ${range}                      ${post_code}[0]

I use the wrong country code
    ${response}=          get on session     ${session}    jh/34510    expected_status=404
    ${wrong_status}=      convert to string  ${response.status_code}
    set global variable   ${wrong_status}

no data is returned and I receive a 404 error
    should be equal       ${wrong_status}           404

4 places are returned
    ${cnt}=    Get length       ${places}[0]
    should be equal as numbers  ${cnt}    4

they are all in the state of England
    FOR	 ${var}	 IN	    @{states}
    should be equal     ${var}    England
    END

each one has a place name, longitude, state, state abbreviation and latitude
    FOR	 ${i}	IN RANGE    4
    should not be equal     ${longitude}[${i}]     NULL
    should not be equal     ${place_name}[${i}]    NULL
    should not be equal     ${state_abv}[${i}]     NULL
    should not be equal     ${latitude}[${i}]      NULL
    END

*** Test Cases ***
Scenario: Type Check
   Given I am searching for a postcode
   When I make a valid request     us    90210
   Then the request contains the following fields and types

Scenario: Request Response Check
    Given I am searching for a postcode
    When I make a valid request    us    90210
    Then the post code returned in the response matches the postcode I pass as a request parameter    us    90210

Scenario: Invalid Post Code Check
    Given I am searching for a postcode
    When I use the wrong country code
    Then no data is returned and I receive a 404 error

Scenario: Places Check
    Given I am searching for a postcode
    When I make a valid request    gb    GU22
    Then 4 places are returned
    And they are all in the state of England
    And each one has a place name, longitude, state, state abbreviation and latitude



