module Main exposing (main)

import Browser
import Element exposing (Element, el, text)
import GitHub.Object
import GitHub.Object.User as User
import GitHub.Query as Query
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import RemoteData exposing (RemoteData(..))


endpoint : String
endpoint =
    "https://api.github.com/graphql"


type alias User =
    { login : String
    }


type alias Response =
    { user : User }


query : SelectionSet User RootQuery
query =
    Query.viewer userSelection


userSelection : SelectionSet User GitHub.Object.User
userSelection =
    SelectionSet.map User
        User.login


fetchUser : String -> Cmd Msg
fetchUser token =
    query
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withHeader "authorization" ("Bearer " ++ token)
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)



-- MAIN


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    RemoteData (Graphql.Http.Error User) User



-- UPDATE


type Msg
    = GotResponse Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotResponse response ->
            ( response, Cmd.none )



-- INIT


type alias Flags =
   String


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( NotAsked, fetchUser flags )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [] (viewUser model)


viewUser : Model -> Element msg
viewUser model =
    case model of
        NotAsked ->
            el [] (text "NotAsked")

        Loading ->
            el [] (text "Loading...")

        Failure httpError ->
            el [] (text "Failed!")

        Success user ->
            el [] (text user.login)
