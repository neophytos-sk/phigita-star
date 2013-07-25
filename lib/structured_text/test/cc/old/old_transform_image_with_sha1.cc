std::string sha1(const std::string& secret_token) {
  char secret[41];
  SHA1 sha;
  sha.Input(secret_token.data(),secret_token.size());
  unsigned message_digest_array[5];
  if (!sha.Result(message_digest_array)) return "";

  sprintf(secret, "%08X%08X%08X%08X%08X",
	  message_digest_array[0],
	  message_digest_array[1],
	  message_digest_array[2],
	  message_digest_array[3],
	  message_digest_array[4]);
  
  return std::string(secret);
}


void transform_image(const char *p, st_md_t *md, std::string& html) {


  // TODO: turn the following into a struct config_s
  std::string root = "10-814";  // class_id + '-' + context_user_id
  std::string object_id = "1112";
  std::string image_prefix = "/~k2pts/blog/";
  bool secure_p = true;

  std::string image_url;
  std::string image_id(p+7,(int)(md->ptr[0]-(p+7)));
  if (secure_p) {
    char buf[30];
    time_t rawtime;
    time(&rawtime);
    sprintf(buf,"%d",(int) rawtime);
    std::string seconds(buf);
    std::string secret_token;
    secret_token += "sEcReT-iMaGe-" + root + "-" + image_id + "-";
    secret_token += seconds;
    secret_token += "-" + object_id;

    std::string secret = sha1(secret_token);
    image_url += image_prefix + "image/" + image_id + "-";
    image_url += secret;
    image_url += "-";
    image_url += seconds;
    image_url += "-" + object_id;
  } else {
    image_url = image_prefix + "image/" + image_id;
  }

  html += "<__image__ id=\"" + image_url + "\"";

  const char *inner_text_end = md->ptr[2];
  if (md->ptr[1]) {
    html += " caption=\"" +  std::string(md->ptr[1]+1,(int)(md->ptr[2]-(md->ptr[1]+1)))  + "\"";
    
    inner_text_end = md->ptr[1];
  }

  if (!only_spaces(md->ptr[0],inner_text_end)) {
    html += " align=\"" + std::string(md->ptr[0],(int)(inner_text_end-md->ptr[0])) + "\""; 
			     
  }

  html += " />";

  md->ptr[0] = NULL;
  md->ptr[1] = NULL;
  md->ptr[2] = NULL;
}
