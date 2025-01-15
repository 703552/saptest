@EndUserText.label: 'Data Definition for Demo'
@ObjectModel.query.implementedBy: 'ABAP:ZCDS_CLASS'
define custom entity ZCDS_REPORT
{

    @UI.selectionField: [{ position: 1 }]
      @UI.lineItem: [{ position: 1, label: 'Plant' }] 
     // @Consumption.valueHelpDefinition: [{ entity : { element: 'Plant', name: 'I_ProductPlantStdVH' } }]
      key Plant   : abap.char(4);
      
      @UI.selectionField: [{ position: 2 }]
      @UI.lineItem: [{ position: 2, label: 'Material' }] 
      @Consumption.valueHelpDefinition: [{ entity : { element: 'Material', name: 'C_BOMMaterialVH' } }]
       Material   : abap.char(40);
       
      @UI.selectionField: [{ position: 3 }]
      @UI.lineItem: [{ position: 3, label: 'BOM' }] 
       BOM   : abap.char(8);  
       
      @UI.selectionField: [{ position: 4 }]
      @UI.lineItem: [{ position: 4, label: 'Alternative BOM' }] 
       ABOM   : abap.char(2);
       
      @UI.selectionField: [{ position: 5 }]
      @UI.lineItem: [{ position: 5, label: 'Production Version' }] 
       PV   : abap.char(4); 
  
}
