{- This file re-implements the Elm Counter example (1 counter) with elm-mdl
   buttons. Use this as a starting point for using elm-mdl components in your own
   app.
-}


module Main exposing (Mdl, Model, Msg(..), main, model, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Material
import Material.Button as Button
import Material.Color as Color
import Material.Layout as Layout
import Material.Options as Options
import Material.Scheme
import Material.Textfield as Textfield



-- MODEL


type alias Model =
    { mdl :
        Material.Model
    , selectedTab : Int
    , linkToDownload : String
    }


model : Model
model =
    { mdl =
        Material.model
    , selectedTab = 0
    , linkToDownload = ""
    }



-- ACTION, UPDATE


type Msg
    = Mdl (Material.Msg Msg)
    | SelectTab Int
    | UpdateLinkToDownload String
    | DownloadLink
    | DownloadLaunched (Result Http.Error String)
    | DownloadFinished (Result Http.Error String)



-- Boilerplate: Msg clause for internal Mdl messages.


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Boilerplate: Mdl action handler.
        Mdl msg_ ->
            Material.update Mdl msg_ model

        SelectTab num ->
            ( { model | selectedTab = num }, Cmd.none )

        UpdateLinkToDownload link ->
            ( { model | linkToDownload = link }, Cmd.none )

        DownloadLink ->
            ( model, downloadYoutubeLink model.linkToDownload )

        _ ->
            ( model, Cmd.none )



-- VIEW


type alias Mdl =
    Material.Model


viewYoutubeDownload : Model -> Html Msg
viewYoutubeDownload model =
    div []
        [ Textfield.render Mdl
            [ 0 ]
            model.mdl
            [ Textfield.label "Link to download"
            , Textfield.floatingLabel
            , Textfield.text_
            , Options.onInput UpdateLinkToDownload
            ]
            []
        , Button.render Mdl
            [ 1 ]
            model.mdl
            [ Button.ripple
            , Options.onClick DownloadLink
            ]
            [ text "Download link" ]
        ]


viewBody : Model -> Html Msg
viewBody model =
    case model.selectedTab of
        0 ->
            viewYoutubeDownload model

        _ ->
            div [] [ text "How did you get here ?" ]


view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.Blue Color.Cyan <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.onSelectTab SelectTab
            , Layout.selectedTab model.selectedTab
            ]
            { header = [ h3 [ style [ ( "padding", "2rem" ) ] ] [ text "Welcome FDP !" ] ]
            , drawer = []
            , tabs = ( [ text "Download youtube video" ], [ Color.background (Color.color Color.Blue Color.S400) ] )
            , main = [ viewBody model ]
            }



-- Load Google Mdl CSS. You'll likely want to do that not in code as we
-- do here, but rather in your master .html file. See the documentation
-- for the `Material` module for details.


main : Program Never Model Msg
main =
    Html.program
        { init = ( model, Cmd.none )
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }



-- FUNCTIONS


downloadYoutubeLink : String -> Cmd Msg
downloadYoutubeLink link =
    Http.send DownloadLaunched <|
        Http.post "{{ HTTP_URL }}/download_youtube_link" (encodeLink link) Decode.string


encodeLink : String -> Http.Body
encodeLink link =
    Http.jsonBody <|
        Encode.object [ ( "link", Encode.string link ) ]
