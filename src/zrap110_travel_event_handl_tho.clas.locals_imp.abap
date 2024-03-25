*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lhe_travel DEFINITION INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.
    METHODS get_uuid RETURNING VALUE(uuid) TYPE sysuuid_x16.

    METHODS on_travel_accepted FOR ENTITY EVENT
       accepted FOR travel~travel_accepted.

    METHODS on_travel_rejected FOR ENTITY EVENT
       rejected FOR travel~travel_rejected.
ENDCLASS.


CLASS lhe_travel IMPLEMENTATION.

  METHOD get_uuid.
    TRY.
        uuid = cl_system_uuid=>create_uuid_x16_static( ) .
      CATCH cx_uuid_error.
    ENDTRY.
  ENDMETHOD.

  METHOD on_travel_accepted.
    "close the active modify phase
    cl_abap_tx=>save( ).
    "loop over transfered travel instances and do the needful :)
    LOOP AT accepted REFERENCE INTO DATA(lr_accepted).
      DATA lr_travel_accepted TYPE zrap110_etravtho.
      MOVE-CORRESPONDING lr_accepted->* TO lr_travel_accepted.
      lr_travel_accepted-uuid = get_uuid( ).
      lr_travel_accepted-travel_id = lr_accepted->%key-TravelID.
      lr_travel_accepted-event_name = 'travel_accepted'.
      lr_travel_accepted-created_at = utclong_current( ).
      "insert to db
      INSERT zrap110_etravtho FROM @lr_travel_accepted.
    ENDLOOP.

  ENDMETHOD.

  METHOD on_travel_rejected.
    "close the active modify phase
    cl_abap_tx=>save( ).
    "loop over transfered travel instances and do the needful :)
    LOOP AT rejected REFERENCE INTO DATA(lr_rejected).
      DATA lr_travel_rejected TYPE zrap110_etravtho.
      lr_travel_rejected-uuid = get_uuid( ).
      lr_travel_rejected-travel_id = lr_rejected->%key-TravelID.
      lr_travel_rejected-event_name = 'travel_rejected'.
      lr_travel_rejected-created_at = utclong_current( ).
      "insert to db
      INSERT zrap110_etravtho FROM @lr_travel_rejected.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
