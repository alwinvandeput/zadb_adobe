CLASS zadb_unit_test_dp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF t_doc_item,
        item_no TYPE string,
        material_no type vbap-matnr,
      END OF t_doc_item,

      BEGIN OF t_document_data,
        order_no    TYPE vbak-vbeln,
        create_date TYPE vbak-erdat,
        items       TYPE STANDARD TABLE OF t_doc_item WITH EMPTY KEY,
      END OF t_document_data.

    METHODS constructor
      IMPORTING sales_order_no TYPE vbak-vbeln.

    METHODS get_document_data
      RETURNING VALUE(document_data) TYPE t_document_data.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA m_sales_order_no TYPE vbak-vbeln.

ENDCLASS.

CLASS zadb_unit_test_dp IMPLEMENTATION.

  METHOD constructor.

    m_sales_order_no = sales_order_no.

  ENDMETHOD.

  METHOD get_document_data.

    document_data = VALUE #(
      order_no        = |{ m_sales_order_no ALPHA = OUT }|
      create_date     = '20220715'
      items = value #(
        (
          item_no = |{ '000010' alpha = out }|
          material_no = 'AAA111333'
        )
      )
    ).

  ENDMETHOD.


ENDCLASS.
