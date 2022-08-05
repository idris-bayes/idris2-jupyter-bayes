module VegaPlot

import Language.JSON
import Idris2JupyterVega.VegaLite

export
scatterGraph : List (Double, Double) -> VegaLite
scatterGraph vals = TopLevelSpec_0 $ MkTopLevelUnitSpec
    {Schema = Just "https://vega.github.io/schema/vega-lite/v5.json"}
    (Data_0 $ Data_0 $ DataSource_1 $ MkInlineData $ InlineDataset_3 $ map (\(x, y) => JObject [("x", JNumber x), ("y", JNumber y)]) vals)
    {description = Just "A scatterplot"}
    {encoding = Just $ MkFacetedEncoding
        {x = Just $ PositionDef_0 $ MkPositionFieldDef
            {field = Just $ Field_0 "x"}
            {type = Just StandardTypeQuantitative}
        }
        {y = Just $ PositionDef_0 $ MkPositionFieldDef
            {field = Just $ Field_0 "y"}
            {type = Just StandardTypeQuantitative}
        }
    }
    {mark = AnyMark_2 MarkPoint}

export
barChart : String -> List (String, Double) -> VegaLite
barChart description vals = TopLevelSpec_0 $ MkTopLevelUnitSpec
    {Schema = Just "https://vega.github.io/schema/vega-lite/v5.json"}
    (Data_0 $ Data_0 $ DataSource_1 $ MkInlineData $ InlineDataset_3 $ map (\(name, x) => JObject [("a", JString name), ("b", JNumber x)]) vals)
    {description = Just description}
    {encoding = Just $ MkFacetedEncoding
        {x = Just $ PositionDef_0 $ MkPositionFieldDef
            {axis = Just $ Axis_0 $ MkAxis {labelAngle = Just $ LabelAngle_0 0}}
            {field = Just $ Field_0 "a"}
            {type = Just StandardTypeNominal}
        }
        {y = Just $ PositionDef_0 $ MkPositionFieldDef
            {field = Just $ Field_0 "b"}
            {type = Just StandardTypeQuantitative}
        }
    }
    (AnyMark_2 MarkBar)
