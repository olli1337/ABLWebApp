@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
/*------------------------------------------------------------------------
   File        : Lion
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : olli
   Created     : Fri Jan 06 01:10:11 EET 2017
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Lion: 

    DEFINE TEMP-TABLE addCat LIKE Cat.
    DEFINE TEMP-TABLE getCat LIKE Cat.
    DEFINE TEMP-TABLE updateCat LIKE Cat.
    
    DEFINE DATASET catSet FOR updateCat.

    /*------------------------------------------------------------------------------
     Purpose: Create a cat.
     Notes:
    ------------------------------------------------------------------------------*/

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    METHOD PUBLIC VOID CreateCat(INPUT catName AS CHARACTER, colour AS CHARACTER, OUTPUT successMessage AS CHARACTER, OUTPUT success AS LOGICAL):

        CREATE addCat.
       
        ASSIGN     
            addCat.Name   = catName
            addCat.Colour = colour
            addCat.Id     = GetNewId().

        BUFFER-COPY addCat TO Cat.
        
        successMessage = "Record created!".
        success = TRUE.

        RETURN.

    END METHOD.



    /*------------------------------------------------------------------------------
     Purpose: Get all cats.
     Notes:
    ------------------------------------------------------------------------------*/

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    METHOD PUBLIC VOID FetchCats( OUTPUT TABLE getCat, OUTPUT success AS LOGICAL, OUTPUT successMessage AS CHARACTER ):
		
        EMPTY TEMP-TABLE getCat.
        
        FOR EACH Cat NO-LOCK:
            
            CREATE getCat.
            BUFFER-COPY Cat TO getCat.
            
        END.
        
        successMessage = "Cats fetched successfully!".
        success = TRUE.
		
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Get single cat.
     Notes:
    ------------------------------------------------------------------------------*/

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    METHOD PUBLIC VOID GetCat(INPUT catId AS INTEGER, OUTPUT TABLE getCat, OUTPUT successMessage AS CHARACTER, OUTPUT success AS LOGICAL):
        
        MESSAGE "GETTING CAT!".
        
        EMPTY TEMP-TABLE getCat.
        
        FIND FIRST Cat WHERE Cat.Id EQ catId NO-LOCK NO-ERROR.
        
        IF AVAILABLE Cat THEN 
        DO:       
            CREATE getCat.
            BUFFER-COPY Cat TO getCat.
                
            successMessage = "Cat fetched successfully!".
            success = TRUE.   
        END. 
        ELSE 
        DO:      
            successMessage = "Cat not found!".
            success = FALSE.
        END.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Remove a cat.
     Notes:
    ------------------------------------------------------------------------------*/

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    METHOD PUBLIC VOID RemoveCat( INPUT catId AS INTEGER, OUTPUT successMessage AS CHARACTER, OUTPUT success AS LOGICAL ):

        FIND FIRST Cat WHERE Cat.Id EQ catID EXCLUSIVE-LOCK NO-ERROR.
        
        IF AVAILABLE Cat THEN 
        DO:    
            DELETE Cat.
            successMessage = "Cat removed successfully!".
            success = TRUE.    
        END. 
        ELSE 
        DO: 
            successMessage = "Cat not found!".
            success = FALSE.   
        END.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Update a cat.
     Notes:
    ------------------------------------------------------------------------------*/

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    METHOD PUBLIC VOID UpdateCat(INPUT catId AS INTEGER, INPUT DATASET catSet, OUTPUT successMessage AS CHARACTER, OUTPUT success AS LOGICAL ):
        
        FIND FIRST updateCat.
        
        FIND FIRST Cat WHERE Cat.Id EQ catId EXCLUSIVE-LOCK NO-ERROR.
        
        ASSIGN
            updateCat.Id = catId.
        
        IF AVAILABLE Cat THEN 
        DO:    
            BUFFER-COPY updateCat TO Cat.
            successMessage = "Record updated!".
            success = TRUE.
            
        END. 
        ELSE 
        DO: 
            successMessage = "Record not found!".
            success = FALSE.
        END.

    END METHOD.    

    /*------------------------------------------------------------------------------
     Purpose: Generate an ID for a new cat.
     Notes:
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC INTEGER GetNewId():
                
        DEFINE VARIABLE catId AS INTEGER INIT 0.
            
        FIND LAST Cat NO-LOCK NO-ERROR.
        
        IF AVAILABLE Cat THEN 
        DO: 
            catId = Cat.Id.
        END.
        
        REPEAT:
            
            FIND FIRST Cat WHERE Cat.Id = catId + 1 NO-LOCK NO-ERROR.     
            catId = catId + 1.       
            IF NOT AVAILABLE CAT THEN LEAVE.
                      
        END.
            
        RETURN catId.

    END METHOD.

END CLASS.