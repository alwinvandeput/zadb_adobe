CLASS unit_test DEFINITION FINAL FOR TESTING
  DURATION LONG
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_01 FOR TESTING.

ENDCLASS.

CLASS unit_test IMPLEMENTATION.

  METHOD test_01.

    "This unit test must be executed in the SAP Gui on the foreground.

    TRY.

        DATA sales_order_no TYPE vbak-vbeln.
        sales_order_no = '0000000004'.

        DATA(data_provider) = NEW zadb_unit_test_dp( sales_order_no ).

        DATA(document_data) = data_provider->get_document_data( ).

        DATA(adobe_document) = NEW zadb_adobe_document(
          VALUE #(
            form_name            = 'ZADB_UNIT_TEST'
            language_code        = 'E'
            country_code         = 'GB'
            document_data_object = REF #( document_data )
          )
        ).

        adobe_document->get_pdf(
          dialog_ind  = abap_true
          print_destination = 'LP01' ).

      CATCH zcx_return3 INTO DATA(return3_exc).

        cl_abap_unit_assert=>fail( msg = return3_exc->get_text(  ) ).

    ENDTRY.

  ENDMETHOD.

ENDCLASS.
