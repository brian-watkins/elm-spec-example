module Helpers exposing (..)

import Spec.Http.Stub as Stub
import Spec.Http.Route as Route
import Json.Encode as Encode
import Main as App


testFlags : App.Flags
testFlags =
  { apiBaseURL = "http://testing-only.com/api"
  }

testAccessTokenUrl =
  testFlags.apiBaseURL ++ "/accessToken"

testThingsUrl =
  testFlags.apiBaseURL ++ "/things"

testAccessToken =
  "my-fake-access-token"

successfulAccessTokenStub =
  Stub.for (Route.get testAccessTokenUrl)
    |> Stub.withBody (Stub.withJson <| Encode.string testAccessToken)

failedAccessTokenStub =
  Stub.for (Route.get testAccessTokenUrl)
    |> Stub.withStatus 403

successfulThingsStub =
  Stub.for (Route.get testThingsUrl)
    |> Stub.withBody (Stub.withJson <|
      Encode.list Encode.string [ "birds", "fish", "trees" ]
    )

failedThingsStub =
  Stub.for (Route.get testThingsUrl)
    |> Stub.withStatus 403
