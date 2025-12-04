//disable TOC button
window.HelpViewer.showTOCButton(true);

//enable TOC button
//If you call this on window load it will flash active for a brief second and then disable again.
//Call if after a delay of 250ms and is works fine
//Not sure what the second variable does yet, but passing false works fine
window.HelpViewer.showTOCButton( true, false, false) {
	 //do something to toggle TOC in your webpage
});

//Apple stores the status of the TOC using a window session variable. 
//You can use this to keep the TOC open or closed
//when transitioning between pages.

window.sessionStorage.getItem("toc");
