#ifndef VariantsPlusH
#define VariantsPlusH

template<class TYPE>
TVariant __fastcall RecordInVariant(TYPE TRecord)
// This functions copies any type entirely into a variant
// pre  TRecord contains the type to be copied
// post  The function returns the TVariant containing the type.

template<class TYPE2>
void __fastcall RecordOutVariant(TVariant *TV, TYPE2 *Record)
// This function copies the contents of a variant into a type.
// You must be sure that the variant is really containing the right type
// pre: TV: TVariant containing the type.
// post: Record contains the type

#endif

/*
  EXAMPLE: PUTTING THE DATA IN THE VARIANT
{
  TVariant MyVariant;
  TSomeRecord *MyRecord;
  MyRecord = new TSomeRecord;
  // todo: put data in the record
  MyVariant = RecordInVariant(*MyRecord);
}


  EXAMPLE: GETTING THE DATAOUT OF THE VARIANT
{
  TVariant MyVariant;
  TSomeRecord *MyRecord;
  MyRecord = new TSomeRecord;
  RecordOutVariant(&MyVariant, MyRecord);
  // todo: do something with the data.
}
*/