CLASS ZCDS_CLASS DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCDS_CLASS IMPLEMENTATION.



    METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF ZCDS_REPORT,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

*      DATA : lv_index          TYPE sy-tabix,
*             lv_previous_plant TYPE I_ProductPlantBasic-Plant,
*             lv_current_plant  TYPE I_ProductPlantBasic-Plant.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

*      DATA : curr_date TYPE datum,
*             lv_date   TYPE datum.

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'PLANT'.
          DATA(lt_plant_Code) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'MATERIAL'.
          DATA(lt_Material) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'BOM'.
          DATA(lt_bom) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'ABOM'.
          DATA(lt_abom) = ls_filter_cond-range[].
         ELSEIF ls_filter_cond-name = 'PV'.
          DATA(lt_pv) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

      SELECT
      a~Plant,
      a~Material,
      a~BillOfMaterial,
      a~BillOfMaterialVariant,
      b~ProductionVersion
      FROM I_MaterialBOMLink AS a
            INNER join I_ProductionVersion as b on
               a~Plant = b~Plant
      WHERE a~Plant IN @lt_Plant_Code and
            a~Material in @lt_material and
            a~BillOfMaterial in @lt_bom and
            a~BillOfMaterialVariant in @lt_abom and
            b~ProductionVersion in @lt_pv
      INTO TABLE @DATA(it).

      LOOP AT it INTO DATA(wa).

        ls_response-Plant = wa-Plant.
        ls_response-Material = wa-Material.
        ls_response-bom = wa-BillOfMaterial.
        ls_response-abom = wa-BillOfMaterialVariant.
        ls_response-pv = wa-ProductionVersion.
        APPEND ls_response TO lt_response.

      ENDLOOP.

*DELETE ADJACENT DUPLICATES FROM lt_response COMPARING Plant.  "Only Unique Plants will be shown (no duplicate even when data is different of single plant).
DELETE ADJACENT DUPLICATES FROM lt_response.         "Only Plants with exact similar data will be deleted.

*      SORT lt_response BY PLANT.
*      lv_max_rows = lv_skip + lv_top.
*      IF lv_skip > 0.
*        lv_skip = lv_skip + 1.
*      ENDIF.

*      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).


    ENDIF.
  ENDMETHOD.
ENDCLASS.
