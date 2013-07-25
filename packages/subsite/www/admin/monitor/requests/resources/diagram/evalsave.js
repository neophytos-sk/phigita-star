function EvalSave(ss)
{ var jj="";
  try
  { with (Math) jj=eval(ss);
  }
  catch(error)
  { return("");
  }
  return(jj);
}
