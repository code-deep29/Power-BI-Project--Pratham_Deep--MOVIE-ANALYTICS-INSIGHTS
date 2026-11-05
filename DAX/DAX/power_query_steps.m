// =============================================================================
// MOVIE ANALYTICS AND INSIGHTS  -  POWER QUERY (M) DATA PREPARATION
// Student : Pratham Deep   |   Reg. No : PIET24CD063
//
// Query name in the model: mymoviedb
// These steps follow what the model contains (columns, types and derived
// fields). Adjust the file path to where mymoviedb.csv is stored on your PC and
// compare with Home > Transform data > Applied Steps if you want an exact match.
// =============================================================================
let
    // 1. Load the CSV (9 columns: Release_Date, Title, Overview, Popularity,
    //    Vote_Count, Vote_Average, Original_Language, Genre, Poster_Url)
    Source = Csv.Document(
        File.Contents("C:\Projects\Movie-Analytics-and-Insights\Dataset\mymoviedb.csv"),
        [Delimiter = ",", Columns = 9, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    // 2. Set correct data types
    Typed = Table.TransformColumnTypes(
        Promoted,
        {
            {"Release_Date", type date},
            {"Title", type text},
            {"Overview", type text},
            {"Popularity", type number},
            {"Vote_Count", Int64.Type},
            {"Vote_Average", type number},
            {"Original_Language", type text},
            {"Genre", type text},
            {"Poster_Url", type text}
        },
        "en-US"
    ),

    // 3. Remove broken / blank rows (e.g. a record whose Overview wraps over many
    //    lines in the CSV loads as null fragments)
    NoErrors = Table.RemoveRowsWithErrors(Typed),
    NoNulls = Table.SelectRows(NoErrors, each [Title] <> null and [Popularity] <> null and [Vote_Average] <> null),

    // 4. Drop the column that is not used in the report
    DroppedPoster = Table.RemoveColumns(NoNulls, {"Poster_Url"}),

    // 5. Genre Primary = first genre in the Genre list
    GenrePrimary = Table.AddColumn(
        DroppedPoster,
        "Genre Primary",
        each Text.Trim(Text.Split([Genre], ","){0}),
        type text
    ),

    // 6. Release Year (numeric) extracted from Release_Date
    ReleaseYear = Table.AddColumn(GenrePrimary, "Release Year", each Date.Year([Release_Date]), Int64.Type)
in
    ReleaseYear
