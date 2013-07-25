DB_Class ::Book -is_final_if_no_scope "1" -lmap mk_attribute {
    {String ean13 -maxlen "13"}
    {String title}
    {String description}
    {String categories}
    {String author}
    {String authorlist}
    {String publisher}
    {String year}
    {String pages}
    {String isbn}
    {String price_text}
    {String edition}
    {String prototype}
    {String translation}
    {String photography}
    {String illumincation}
    {String binding}
    {String height}
    {String width}
    {String ddc}
    {String categories}
    {String source}
    {Boolean image_p -isNullable no -default 'f'}
    {Boolean description_p -default 'f'}
    {Numeric price -isNullable no}
}


DB_Class ::Book::Subject -is_final_if_no_scope "1" -lmap mk_attribute {
    {String lang}
    {String ddc}
} -lmap mk_like {
    ::content::Name
}
