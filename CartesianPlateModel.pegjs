/*
CARTESIAN PLATE MODEL GRAMMAR

The goal of this grammar is to parse tabular data about "small bodies" in spaces. Think comets, astereoids and the like.

The data comes in the following format:
(as described here: http://pdssbn.astro.umd.edu/holdings/dif-c-hriv_its_mri-5-tempel1-shape-v2.0/data/tempel1_2012_cart.lbl)

PDS_VERSION_ID = PDS3
LABEL_REVISION_NOTE   = "08 Jan 2013:  T. Farnham;  Created
"

RECORD_TYPE  = "FIXED_LENGTH"
RECORD_BYTES = 80
FILE_RECORDS = 48389

^COUNTS_TABLE       = ("TEMPEL1_2012_CART.WRL",6)
^VERTEX_TABLE       = ("TEMPEL1_2012_CART.WRL",7)
^PLATE_TABLE        = ("TEMPEL1_2012_CART.WRL",16032)

DATA_SET_ID  = "DIF-C-HRIV/ITS/MRI-5-TEMPEL1-SHAPE-V2.0"
PRODUCT_NAME = "CARTESIAN PLATE MODEL FOR THE SURFACE OF COMET TEMPEL 1"
PRODUCT_ID   = "TEMPEL1-CARTESIAN-PLATE-MODEL"
INSTRUMENT_HOST_NAME  = {"DEEP IMPACT FLYBY SPACECRAFT",
                         "DEEP IMPACT IMPACTOR SPACECRAFT",
                         "STARDUST"}
INSTRUMENT_NAME       =
           {"DEEP IMPACT HIGH RESOLUTION INSTRUMENT - VISIBLE CCD",
            "DEEP IMPACT IMPACTOR TARGETING SENSOR - VISIBLE CCD",
            "DEEP IMPACT MEDIUM RESOLUTION INSTRUMENT - VISIBLE CCD",
            "NAVIGATION CAMERA"}
TARGET_NAME           = "9P/TEMPEL 1 (1867 G1)"
START_TIME            = "N/A"
STOP_TIME             = "N/A"
PRODUCT_CREATION_TIME = 2013-01-08

OBJECT     = COUNTS_TABLE
  ROWS               = 1
  ROW_BYTES          = 80
  INTERCHANGE_FORMAT = ASCII
  COLUMNS            = 2
  DESCRIPTION        = "Table that gives the count of vertices and plates
    representing the surface of the numerical shape model.  The shape model
    comprises triangular plates and vertices that are specified in a
    body-fixed cartesian coordinate system."

  OBJECT     = COLUMN
    COLUMN_NUMBER = 1
    NAME          = "NUMVERTICES"
    DESCRIPTION   = "NUMBER OF VERTICES IN SHAPE MODEL"
    DATA_TYPE     = ASCII_INTEGER
    START_BYTE    = 5
    BYTES         = 5
    FORMAT        = "I5"
  END_OBJECT = COLUMN

  OBJECT     = COLUMN
    COLUMN_NUMBER = 2
    NAME          = "NUMPLATES"
    DESCRIPTION   = "NUMBER OF TRIANGULAR PLATES IN SHAPE MODEL"
    DATA_TYPE     = ASCII_INTEGER
    START_BYTE    = 13
    BYTES         = 5
    FORMAT        = "I5"
  END_OBJECT = COLUMN
END_OBJECT = COUNTS_TABLE

OBJECT     = VERTEX_TABLE
  ROWS               = 16022
  ROW_BYTES          = 80
  INTERCHANGE_FORMAT = "ASCII"
  COLUMNS            = 2
  DESCRIPTION        = "Table of vertices of the numerical shape model.
    These are the vertices of plates that approximate the surface
    of the body.

    Each row of this table contains the X, Y and Z coordinates of one vertex
    in a Cartesian coordinate system.

    The row also contains a flag denoting whether the point comes from a
    region well constrained by control points (1), a point constrained by a
    limb silhouette (2) or a point not well constrained (3).
    "

  OBJECT     = COLUMN
    COLUMN_NUMBER = 1
    NAME          = "COORDINATES"
    DESCRIPTION   = "The (x,y,z) coordinates of one vertex in the model"
    UNIT          = "KILOMETER"
    DATA_TYPE     = "ASCII_REAL"
    START_BYTE    = 1
    BYTES         = 27
    ITEMS         = 3
    ITEM_BYTES    = 9
    FORMAT        = "3(F9.4)"
  END_OBJECT = COLUMN

  OBJECT     = COLUMN
    COLUMN_NUMBER = 2
    NAME          = "DERIVATION IDENTIFIER"
    DESCRIPTION   = "Identifier denoting how the vertex was derived"
    DATA_TYPE     = "ASCII_INTEGER"
    START_BYTE    = 35
    BYTES         = 1
    ITEMS         = 1
    ITEM_BYTES    = 1
    FORMAT        = "(I1)"
  END_OBJECT = COLUMN
END_OBJECT = VERTEX_TABLE

OBJECT     = PLATE_TABLE
  ROWS               = 32040
  ROW_BYTES          = 80
  INTERCHANGE_FORMAT = "ASCII"
  COLUMNS            = 2
  DESCRIPTION        = "Table of triangular plates of the numerical shape
    model.  These triangular plates approximate the surface of the body.

    Each row of this table contains three integer offsets that point to three
    vertices from the previous table.  The three entries are the vertices of
    one triangular plate of the shape model, and denote the offset from the
    first row in the table of vertices.  An offset of 0 points to the first
    row in the table of vertices, an offset of 1 to the second row, and so
    on.
    "

  OBJECT     = COLUMN
    COLUMN_NUMBER = 1
    NAME          = "PLATE_VERTICES"
    DESCRIPTION   = "Offsets of the three vertices defining this
      triangular plane. The offsets refer to the vertices listed in
      the preceding vertex table."
    DATA_TYPE     = "ASCII_INTEGER"
    START_BYTE    = 3
    BYTES         = 24
    ITEMS         = 3
    ITEM_BYTES    = 8
    FORMAT        = "3(I8)"
  END_OBJECT = COLUMN

  OBJECT     = COLUMN
    COLUMN_NUMBER = 2
    NAME          = "FLAG"
    DESCRIPTION   = "VRML Flag denoting the end of the facet."
    DATA_TYPE     = "ASCII_INTEGER"
    START_BYTE    = 36
    BYTES         = 2
    ITEMS         = 1
    ITEM_BYTES    = 2
    FORMAT        = "(I2)"
  END_OBJECT = COLUMN

END_OBJECT = PLATE_TABLE
END

*/

contents
	= ws p:int ws f:int ws newline+ points:points plates:plates
    { return { pointCount:p, plateCount: f, points:points, plates:plates} }

points
	= point*

plates
	= plate*

/* ----- Numbers ----- */

number "number"
  = minus? ((int frac?) / (frac)) exp? { return parseFloat(text()); }

decimal_point = "."
digit1_9      = [1-9]
e             = [eE]
exp           = e (minus / plus)? DIGIT+
frac          = decimal_point DIGIT*
int           = s:int_start c:int_continued {return s + c;}
int_start     = zero / digit1_9
int_continued = i:DIGIT* {return i.join('');}
minus         = "-"
plus          = "+"
zero          = "0"

ws "whitespace"
	= ws:[ \t\r]*
	{ return ws.join('');}

newline
	= "\n"

point
	= ws x:number ws y:number ws z:number ws DIGIT ws newline
	{ return {x:x, y:y, z:z} }

plate
	= ws one:index ws two:index ws three:index ws newline
	{ return [one, two, three] }

index
	= i:int
    { return i }


/* ----- Core ABNF Rules ----- */

/* See RFC 4234, Appendix B (http://tools.ietf.org/html/rfc4627). */
DIGIT  = [0-9]

HEXDIG = [0-9a-f]i

