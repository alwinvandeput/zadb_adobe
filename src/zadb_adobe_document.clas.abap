CLASS zadb_adobe_document DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF t_document_data,
        form_name            TYPE fpname,
        language_code        TYPE sfpdocparams-langu,
        country_code         TYPE sfpdocparams-country,
        document_data_object TYPE REF TO data,
      END OF t_document_data.

    METHODS constructor
      IMPORTING document_data TYPE t_document_data.

    METHODS get_pdf
      IMPORTING dialog_ind        TYPE abap_bool
                print_destination type sfpoutputparams-dest
      RETURNING VALUE(pdf_binary) TYPE xstring
      RAISING   zcx_return3.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA m_document_data TYPE t_document_data.

    METHODS _get_outputparams
      IMPORTING dialog_ind          TYPE abap_bool
                print_destination   type sfpoutputparams-dest
      RETURNING VALUE(outputparams) TYPE sfpoutputparams.

ENDCLASS.

CLASS zadb_adobe_document IMPLEMENTATION.

  METHOD constructor.

    me->m_document_data = document_data.

  ENDMETHOD.

  METHOD get_pdf.

    DATA lx_root TYPE REF TO cx_root.
    DATA lx_return3 TYPE REF TO zcx_return3.

    TRY.

        "------------------------------------------------------
        "Set output parameters
        "------------------------------------------------------
        DATA:
          outputparams TYPE sfpoutputparams,
          lv_spool_id  TYPE rspoid.

        outputparams = _get_outputparams(
          dialog_ind        = dialog_ind
          print_destination = print_destination ).

        "------------------------------------------------------
        "Open job
        "------------------------------------------------------
        CALL FUNCTION 'FP_JOB_OPEN'
          CHANGING
            ie_outputparams = outputparams
          EXCEPTIONS
            cancel          = 1
            usage_error     = 2
            system_error    = 3
            internal_error  = 4
            OTHERS          = 5.
        IF sy-subrc <> 0.
          CREATE OBJECT lx_return3.
          lx_return3->add_system_message( ).
          RAISE EXCEPTION lx_return3.
        ENDIF.

        "------------------------------------------------------
        "Get function name
        "------------------------------------------------------
        DATA function_name TYPE funcname.

        "- Remark: errors will be catched by CX_ROOT
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = m_document_data-form_name
          IMPORTING
            e_funcname = function_name.

        "------------------------------------------------------
        "Set document parameters
        "------------------------------------------------------
        DATA ls_doc_params      TYPE sfpdocparams.
        ls_doc_params-langu   = m_document_data-language_code.
        ls_doc_params-country = m_document_data-country_code.

        "------------------------------------------------------
        "Create form
        "------------------------------------------------------
        FIELD-SYMBOLS <document_data> TYPE any.
        ASSIGN m_document_data-document_data_object->* TO <document_data>.

        DATA form_output TYPE fpformoutput.

        CALL FUNCTION function_name
          EXPORTING
            /1bcdwb/docparams  = ls_doc_params
            document_data      = <document_data>
          IMPORTING
            /1bcdwb/formoutput = form_output
          EXCEPTIONS
            usage_error        = 1
            system_error       = 2
            internal_error     = 3
            OTHERS             = 4.

        IF sy-subrc <> 0.
          CREATE OBJECT lx_return3.
          lx_return3->add_system_message( ).
          RAISE EXCEPTION lx_return3.
        ENDIF.

        "------------------------------------------------------
        "Close job
        "------------------------------------------------------
        DATA ls_job_close_result TYPE sfpjoboutput.

        CALL FUNCTION 'FP_JOB_CLOSE'
          IMPORTING
            e_result       = ls_job_close_result
          EXCEPTIONS
            usage_error    = 1
            system_error   = 2
            internal_error = 3
            OTHERS         = 4.

        IF sy-subrc <> 0.
          CREATE OBJECT lx_return3.
          lx_return3->add_system_message( ).
          RAISE EXCEPTION lx_return3.
        ENDIF.

        IF dialog_ind = abap_true.

          IF ls_job_close_result-userexit IS INITIAL.

            IF ls_job_close_result-spoolids IS INITIAL.

              MESSAGE ID 'PO' TYPE 'E' NUMBER '475' INTO DATA(dummy).

              IF sy-subrc <> 0.
                CREATE OBJECT lx_return3.
                lx_return3->add_system_message( ).
                RAISE EXCEPTION lx_return3.
              ENDIF.

            ELSE.

              READ TABLE ls_job_close_result-spoolids INDEX 1 INTO lv_spool_id.
              MESSAGE ID 'PO' TYPE 'S' NUMBER '622' WITH lv_spool_id.

            ENDIF.

          ENDIF.

        ENDIF.

        "------------------------------------------------------
        "Set return PDF binary
        "------------------------------------------------------
        pdf_binary = form_output-pdf.

      CATCH zcx_return3 INTO lx_return3.

        RAISE EXCEPTION lx_return3.

      CATCH cx_root INTO lx_root.

        CREATE OBJECT lx_return3.
        lx_return3->add_exception_object( lx_root ).
        RAISE EXCEPTION lx_return3.

    ENDTRY.

  ENDMETHOD.

  METHOD _get_outputparams.


    IF dialog_ind = abap_false.

      outputparams-nodialog   = abap_true.
      outputparams-getpdf     = abap_true.
      outputparams-preview    = abap_false.
      outputparams-nodialog   = abap_true.
      outputparams-dest       = print_destination.       "Printername
      outputparams-copies     = 1.  "1 copy
      outputparams-dataset    = 'PBFORM'.     "Spoolname
      outputparams-suffix1    = print_destination.       "Spoolname suffix1
      outputparams-suffix2    = sy-uname.     "Spoolname suffix2
      outputparams-cover      = ''.
      outputparams-lifetime   = 8.            "Days
      outputparams-arcmode    = '1'. "1: alleen moet worden afgedrukt,
      outputparams-reqimm = abap_false.

    ENDIF.

    outputparams-connection = 'ADS'.

  ENDMETHOD.

ENDCLASS.
