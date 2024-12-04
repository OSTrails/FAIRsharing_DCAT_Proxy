require 'test_helper'
class MetricCreationTest < ActionDispatch::IntegrationTest

  test 'create a metric record' do
    # The user is needed to get the auth_headers (see bottom of page).
    # They can also be obtained by logging in.
    user = users(:one)
    params = { user: { login: user.username, password: "BkjsLtKJvmmLEMmm5rRp" } }
    post '/users/sign_in', params: params.to_json, headers: headers
    assert_response :success
    result = JSON.parse(body)
    jwt = result['jwt']

    headers = {
      "HTTP_ACCEPT": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer #{jwt}"
    }

    # This query is to determine the ID of record types to be sent when creating
    # the record. These should not change so only checking them once will be sufficient.
    get '/record_types', headers: headers
    assert_response :success
    body = JSON.parse(response.body)
    metric_id = body.select {|b| b['name'] == 'metric'}.first['id']

    # This query retrieves the subjects with which the created
    # metric will be labelled. It should be 'Subject Agnostic' (case sensitive)
    # for metrics but I have used 'one' here as the name because this is
    # in our testing fixtures.
    # N.B. Subject IDs may very occasionally change if there has been
    # an update on the ontologies in our database.
    required_subject_name = 'one'
    subject_ids = []
    get '/subjects', headers: headers
    assert_response :success
    body = JSON.parse(response.body)
    subject_ids << body['data'].select {|b| b['label'] == required_subject_name}.first['id']

    # What else might a metric need? The same technique can be used to
    # find countries, user_defined_tags, etc. etc.

    # The metadata field.
    # This must conform to our JSON schemas, specifically the base fairsharing_record one,
    # the standard one, and the metric one (they are merged and the metadata validated
    # against the combined schema).
    metadata = {
      "identifier": 0,
      "name": "New metric record",
      "homepage": "https://example.com/nmr",
      "abbreviation": "NMR",
      "contacts": [
        {
          "contact_name": "John Smith",
          "contact_orcid": "0000-1111-2222-333X",
          "contact_email": "jsmith@example.com"
        }
      ],
      "description": "This metric record is awesome",
      "status": "ready"
    }

    # This will have the metadata above plus IDs for anything linked to the record.
    # record_type is compulsory.
    params = {
      fairsharing_record: {
        record_type_id: metric_id,
        metadata: metadata,
        subject_ids: subject_ids
      }
    }

    # This creates the record
    post '/fairsharing_records', params: params.to_json, headers: headers
    assert_response :success
    body = JSON.parse(response.body)
    # If the record has been successfully created then it will have an ID and that ID
    # will have been added to the metadata.
    assert_not_empty body['data']['id']
    assert_equal body['data']['id'].to_i, body['data']['attributes']['metadata']['identifier'].to_i
  end

end
