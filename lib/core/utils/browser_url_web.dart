import 'dart:html' as html;

void replaceAppHash(String pathAndQuery) {
  html.window.history.replaceState(null, '', '#$pathAndQuery');
}
