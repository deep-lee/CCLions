/*!
 *
 * ZSSRichTextEditor v1.0
 * http://www.zedsaid.com
 *
 * Copyright 2013 Zed Said Studio
 *
 */

// If we are using iOS or desktop
var isUsingiOS = true;

// THe default callback parameter separator
var defaultCallbackSeparator = '~';

const NodeName = {
    BLOCKQUOTE: "BLOCKQUOTE",
    PARAGRAPH: "P"
};

// The editor object
var ZSSEditor = {};

// These variables exist to reduce garbage (as in memory garbage) generation when typing real fast
// in the editor.
//
ZSSEditor.caretArguments = ['yOffset=' + 0, 'height=' + 0];
ZSSEditor.caretInfo = { y: 0, height: 0 };

// Is this device an iPad
ZSSEditor.isiPad;

// A globally saved selection.  Useful for when the editor loses focus.
ZSSEditor.savedSelection;

// The current editing image
ZSSEditor.currentEditingImage;

// The current editing video
ZSSEditor.currentEditingVideo;

// The current editing link
ZSSEditor.currentEditingLink;

ZSSEditor.focusedField = null;

// The objects that are enabled
ZSSEditor.enabledItems = {};

ZSSEditor.editableFields = {};

ZSSEditor.lastTappedNode = null;

// The default paragraph separator
ZSSEditor.defaultParagraphSeparator = 'p';

// Localization strings
ZSSEditor.localizedEditText = "Edit";

/**
 * The initializer function that must be called onLoad
 */
ZSSEditor.init = function(callbacker, logger) {
    
    ZSSEditor.callbacker = callbacker;
    ZSSEditor.logger = logger;
    
    rangy.init();
    
    // Change a few CSS values if the device is an iPad
    ZSSEditor.isiPad = (navigator.userAgent.match(/iPad/i) != null);
    if (ZSSEditor.isiPad) {
        $('#zss_field_title').addClass('ipad_field_title');
        $('#zss_field_content').addClass('ipad_field_content');
    }
    
    document.execCommand('insertBrOnReturn', false, false);
    document.execCommand('defaultParagraphSeparator', false, this.defaultParagraphSeparator);
    document.execCommand('styleWithCSS', false, false);
    
    var editor = $('div.field').each(function() {
        var editableField = new ZSSField($(this),
                                         ZSSEditor.callbacker);
        var editableFieldId = editableField.getNodeId();
                                             
        ZSSEditor.editableFields[editableFieldId] = editableField;
        ZSSEditor.callback("callback-new-field", "id=" + editableFieldId);
    });
    
	document.addEventListener("selectionchange", function(e) {
		ZSSEditor.currentEditingLink = null;
		// DRM: only do something here if the editor has focus.  The reason is that when the
		// selection changes due to the editor loosing focus, the focusout event will not be
		// sent if we try to load a callback here.
		//
		if (editor.is(":focus")) {
            ZSSEditor.selectionChangedCallback();
            ZSSEditor.sendEnabledStyles(e);
			var clicked = $(e.target);
			if (!clicked.hasClass('zs_active')) {
				$('img').removeClass('zs_active');
			}
		}
	}, false);
    
    $('[contenteditable]').on('paste',function(e) {
        // Ensure we only insert plaintext from the pasteboard
        e.preventDefault();
        var plainText = (e.originalEvent || e).clipboardData.getData('text/plain');
        if (plainText.length > 0) {
            document.execCommand('insertText', false, plainText);
        } else {
            //var joinedArguments = ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments();
            ZSSEditor.callback("callback-paste");
        }
    });

    this.domLoadedCallback();

}; //end

// MARK: - Callbacks

ZSSEditor.callback = function(callbackScheme, callbackPath) {
    this.callbacker.callback(callbackScheme, callbackPath);
};

ZSSEditor.domLoadedCallback = function() {
    this.callback("callback-dom-loaded");
};

ZSSEditor.selectionChangedCallback = function () {
    var joinedArguments = this.getJoinedFocusedFieldIdAndCaretArguments();
    
    this.callback('callback-selection-changed', joinedArguments);
    this.callback("callback-input", joinedArguments);
};

ZSSEditor.stylesCallback = function(stylesArray) {
    
    var stylesString = '';
    
    if (stylesArray.length > 0) {
        stylesString = stylesArray.join(defaultCallbackSeparator);
    }
    
    this.callback("callback-selection-style", stylesString);
};

// MARK: - Logging

ZSSEditor.log = function(msg) {
    this.logger.log(msg);
};

// MARK: - Debugging logs

ZSSEditor.logMainElementSizes = function() {
    msg = 'Window [w:' + $(window).width() + '|h:' + $(window).height() + ']';
    this.log(msg);
    
    var msg = encodeURIComponent('Viewport [w:' + window.innerWidth + '|h:' + window.innerHeight + ']');
    this.log(msg);
    
    msg = encodeURIComponent('Body [w:' + $(document.body).width() + '|h:' + $(document.body).height() + ']');
    this.log(msg);
    
    msg = encodeURIComponent('HTML [w:' + $('html').width() + '|h:' + $('html').height() + ']');
    this.log(msg);
    
    msg = encodeURIComponent('Document [w:' + $(document).width() + '|h:' + $(document).height() + ']');
    this.log(msg);
};

// MARK: - Viewport Refreshing

ZSSEditor.refreshVisibleViewportSize = function() {
    $(document.body).css('min-height', window.innerHeight + 'px');
    $('#zss_field_content').css('min-height', (window.innerHeight - $('#zss_field_content').position().top) + 'px');
};

// MARK: - Fields

ZSSEditor.focusFirstEditableField = function() {
    $('div[contenteditable=true]:first').focus();
};

ZSSEditor.getField = function(fieldId) {
    
    var field = this.editableFields[fieldId];

    return field;
};

ZSSEditor.getFocusedField = function() {
    var currentField = $(this.closerParentNodeWithName('div'));
    var currentFieldId = currentField.attr('id');
    
    while (currentField
           && (!currentFieldId || this.editableFields[currentFieldId] == null)) {

        var newField = this.closerParentNodeStartingAtNode('div', currentField);
        if (newField) {
            currentField = newField;
            currentFieldId = currentField.attr('id');
        } else {
            currentField = newField;
        }
    }
    
    return this.editableFields[currentFieldId];
};

// MARK: - Selection

ZSSEditor.backupRange = function(){
	this.savedSelection = rangy.saveSelection()
};

ZSSEditor.restoreRange = function(){
    if (this.savedSelection) {
		rangy.restoreSelection(this.savedSelection);
    }
};

ZSSEditor.getSelectedText = function() {
	var selection = window.getSelection();
	
	return selection.toString();
};

ZSSEditor.getCaretArguments = function() {
    var caretInfo = this.getYCaretInfo();
    
    if (caretInfo == null) {
        return null;
    } else {
        this.caretArguments[0] = 'yOffset=' + caretInfo.y;
        this.caretArguments[1] = 'height=' + caretInfo.height;
        return this.caretArguments;
    }
};

ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments = function() {
    
    var joinedArguments = ZSSEditor.getJoinedCaretArguments();
    var focusedField = ZSSEditor.getFocusedField();
    if (focusedField) {
        var idArgument = "id=" + focusedField.getNodeId();
        joinedArguments = idArgument + defaultCallbackSeparator + joinedArguments;
    }
    return joinedArguments;
};

ZSSEditor.getJoinedCaretArguments = function() {
    
    var caretArguments = this.getCaretArguments();
    var joinedArguments = this.caretArguments.join(defaultCallbackSeparator);
    
    return joinedArguments;
};

ZSSEditor.getCaretYPosition = function() {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var span = document.createElement("span");
    // Ensure span has dimensions and position by
    // adding a zero-width space character
    span.appendChild( document.createTextNode("\u200b") );
    range.insertNode(span);
    var y = span.offsetTop;
    var spanParent = span.parentNode;
    spanParent.removeChild(span);
    
    // Glue any broken text nodes back together
    spanParent.normalize();
    
    return y;
}

ZSSEditor.getYCaretInfo = function() {
    var selection = window.getSelection();
    var noSelectionAvailable = selection.rangeCount == 0;
    
    if (noSelectionAvailable) {
        return null;
    }
    
    var y = 0;
    var height = 0;
    var range = selection.getRangeAt(0);
    var needsToWorkAroundNewlineBug = (range.getClientRects().length == 0);
    
    // PROBLEM: iOS seems to have problems getting the offset for some empty nodes and return
    // 0 (zero) as the selection range top offset.
    //
    // WORKAROUND: To fix this problem we use a different method to obtain the Y position instead.
    //
    if (needsToWorkAroundNewlineBug) {
        var closerParentNode = ZSSEditor.closerParentNode();
        var closerDiv = ZSSEditor.closerParentNodeWithName('div');
        
        var fontSize = $(closerParentNode).css('font-size');
        var lineHeight = Math.floor(parseInt(fontSize.replace('px','')) * 1.5);
        
        y = this.getCaretYPosition();
        height = lineHeight;
    } else {
        if (range.getClientRects) {
            var rects = range.getClientRects();
            if (rects.length > 0) {
                // PROBLEM: some iOS versions differ in what is returned by getClientRects()
                // Some versions return the offset from the page's top, some other return the
                // offset from the visible viewport's top.
                //
                // WORKAROUND: see if the offset of the body's top is ever negative.  If it is
                // then it means that the offset we have is relative to the body's top, and we
                // should add the scroll offset.
                //
                var addsScrollOffset = document.body.getClientRects()[0].top < 0;
                
                if (addsScrollOffset) {
                    y = document.body.scrollTop;
                }
                
                y += rects[0].top;
                height = rects[0].height;
            }
        }
    }
    
    this.caretInfo.y = y;
    this.caretInfo.height = height;
    
    return this.caretInfo;
};

// MARK: - Default paragraph separator

ZSSEditor.defaultParagraphSeparatorTag = function() {
    return '<' + this.defaultParagraphSeparator + '>';
};

// MARK: - Styles

ZSSEditor.setBold = function() {
	document.execCommand('bold', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setItalic = function() {
	document.execCommand('italic', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setSubscript = function() {
	document.execCommand('subscript', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setSuperscript = function() {
	document.execCommand('superscript', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setStrikeThrough = function() {
	var commandName = 'strikeThrough';
	var isDisablingStrikeThrough = ZSSEditor.isCommandEnabled(commandName);
	
	document.execCommand(commandName, false, null);
	
	// DRM: WebKit has a problem disabling strikeThrough when the tag <del> is used instead of
	// <strike>.  The code below serves as a way to fix this issue.
	//
	var mustHandleWebKitIssue = (isDisablingStrikeThrough
								 && ZSSEditor.isCommandEnabled(commandName));
	
	if (mustHandleWebKitIssue) {
		var troublesomeNodeNames = ['del'];
		
		var selection = window.getSelection();
		var range = selection.getRangeAt(0).cloneRange();
		
		var container = range.commonAncestorContainer;
		var nodeFound = false;
		var textNode = null;
		
		while (container && !nodeFound) {
			nodeFound = (container
						 && container.nodeType == document.ELEMENT_NODE
						 && troublesomeNodeNames.indexOf(container.nodeName.toLowerCase()) > -1);
			
			if (!nodeFound) {
				container = container.parentElement;
			}
		}
		
		if (container) {
			var newObject = $(container).replaceWith(container.innerHTML);
			
			var finalSelection = window.getSelection();
			var finalRange = selection.getRangeAt(0).cloneRange();
			
			finalRange.setEnd(finalRange.startContainer, finalRange.startOffset + 1);
			
			selection.removeAllRanges();
			selection.addRange(finalRange);
		}
	}
	
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setUnderline = function() {
	document.execCommand('underline', false, null);
	ZSSEditor.sendEnabledStyles();
};

/**
 *  @brief      Turns blockquote ON or OFF for the current selection.
 *  @details    This method makes sure that the contents of the blockquotes are surrounded by the
 *              defaultParagraphSeparatorTag (by default '<p>').  This ensures parity with the web
 *              editor.
 */
ZSSEditor.setBlockquote = function() {

    var savedSelection = rangy.saveSelection();
    var selection = document.getSelection();
    var range = selection.getRangeAt(0).cloneRange();
    var sendStyles = false;
    
    var ancestorElement = this.getAncestorElementForSettingBlockquote(range);
    
    if (ancestorElement) {
        sendStyles = true;
        
        var childNodes = this.getChildNodesIntersectingRange(ancestorElement, range);
        
        if (childNodes && childNodes.length) {
            this.toggleBlockquoteForSpecificChildNodes(ancestorElement, childNodes);
        }
    }
    
    rangy.restoreSelection(savedSelection);
    
    if (sendStyles) {
        ZSSEditor.sendEnabledStyles();
    }
};

ZSSEditor.removeFormating = function() {
	document.execCommand('removeFormat', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setHorizontalRule = function() {
	document.execCommand('insertHorizontalRule', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setHeading = function(heading) {
	var formatTag = heading;
	var formatBlock = document.queryCommandValue('formatBlock');
	
	if (formatBlock.length > 0 && formatBlock.toLowerCase() == formatTag) {
		document.execCommand('formatBlock', false, this.defaultParagraphSeparatorTag());
	} else {
		document.execCommand('formatBlock', false, '<' + formatTag + '>');
	}
	
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setParagraph = function() {
	var formatTag = "p";
	var formatBlock = document.queryCommandValue('formatBlock');
	
	if (formatBlock.length > 0 && formatBlock.toLowerCase() == formatTag) {
		document.execCommand('formatBlock', false, this.defaultParagraphSeparatorTag());
	} else {
		document.execCommand('formatBlock', false, '<' + formatTag + '>');
	}
	
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.undo = function() {
	document.execCommand('undo', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.redo = function() {
	document.execCommand('redo', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setOrderedList = function() {
    document.execCommand('insertOrderedList', false, null);
    ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setUnorderedList = function() {
	document.execCommand('insertUnorderedList', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setJustifyCenter = function() {
	document.execCommand('justifyCenter', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setJustifyFull = function() {
	document.execCommand('justifyFull', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setJustifyLeft = function() {
	document.execCommand('justifyLeft', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setJustifyRight = function() {
	document.execCommand('justifyRight', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setIndent = function() {
	document.execCommand('indent', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setOutdent = function() {
	document.execCommand('outdent', false, null);
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.setTextColor = function(color) {
    ZSSEditor.restoreRange();
	document.execCommand("styleWithCSS", null, true);
	document.execCommand('foreColor', false, color);
	document.execCommand("styleWithCSS", null, false);
	ZSSEditor.sendEnabledStyles();
    // document.execCommand("removeFormat", false, "foreColor"); // Removes just foreColor
};

ZSSEditor.setBackgroundColor = function(color) {
	ZSSEditor.restoreRange();
	document.execCommand("styleWithCSS", null, true);
	document.execCommand('hiliteColor', false, color);
	document.execCommand("styleWithCSS", null, false);
	ZSSEditor.sendEnabledStyles();
};

// Needs addClass method

ZSSEditor.insertLink = function(url, title) {

    ZSSEditor.restoreRange();

    var sel = document.getSelection();
	if (sel.rangeCount) {
		var range = sel.getRangeAt(0).cloneRange();
		
		var el = document.createElement("a");
		el.setAttribute("href", url);
		
		range.surroundContents(el);
		el.innerHTML = title;
		
		range.setStartAfter(el);
		range.setEndAfter(el);
		
		sel.removeAllRanges();
		sel.addRange(range);
	}

	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.updateLink = function(url, title) {
	
    ZSSEditor.restoreRange();
	
    var currentLinkNode = ZSSEditor.lastTappedNode;
	
    if (currentLinkNode) {
		currentLinkNode.setAttribute("href", url);
		currentLinkNode.innerHTML = title;
    }
    ZSSEditor.sendEnabledStyles();
};

ZSSEditor.unlink = function() {
    
	var currentLinkNode = ZSSEditor.closerParentNodeWithName('a');
    
	if (currentLinkNode) {
		this.unwrapNode(currentLinkNode);
	}
	
	ZSSEditor.sendEnabledStyles();
};

ZSSEditor.unwrapNode = function(node) {
    var savedSelection = rangy.saveSelection();
    
    $(node).contents().unwrap();
    
    rangy.restoreSelection(savedSelection);
};

ZSSEditor.wrapNode = function(node) {
    var savedSelection = rangy.saveSelection();
    
    $(node).contents().wrap("<p></p>");
    
    rangy.restoreSelection(savedSelection);
};

ZSSEditor.quickLink = function() {
	
	var sel = document.getSelection();
	var link_url = "";
	var test = new String(sel);
	var mailregexp = new RegExp("^(.+)(\@)(.+)$", "gi");
	if (test.search(mailregexp) == -1) {
		checkhttplink = new RegExp("^http\:\/\/", "gi");
		if (test.search(checkhttplink) == -1) {
			checkanchorlink = new RegExp("^\#", "gi");
			if (test.search(checkanchorlink) == -1) {
				link_url = "http://" + sel;
			} else {
				link_url = sel;
			}
		} else {
			link_url = sel;
		}
	} else {
		checkmaillink = new RegExp("^mailto\:", "gi");
		if (test.search(checkmaillink) == -1) {
			link_url = "mailto:" + sel;
		} else {
			link_url = sel;
		}
	}

	var html_code = '<a href="' + link_url + '">' + sel + '</a>';
	ZSSEditor.insertHTML(html_code);
};

// MARK: - Blockquotes

/**
 *  @brief      This method toggles blockquote for the specified child nodes.  This is useful since
 *              we can toggle blockquote either for some or ALL of the child nodes, depending on
 *              what we need to achieve.
 *  @details    CASE 1: If the parent node is a blockquote node, the child nodes will be extracted
 *              from it leaving the remaining siblings untouched (by splitting the parent blockquote
 *              node in two if necessary).
 *              CASE 2: If the parent node is NOT a blockquote node, but the first child is, the
 *              method will make sure all child nodes that are blockquote nodes will be toggled to
 *              non-blockquote nodes.
 *              CASE 3: If both the parent node and the first node are non-blockquote nodes, this
 *              method will turn all child nodes into blockquote nodes.
 *
 *  @param      parentNode      The parent node.  Can be either a blockquote or non-blockquote node.    
 *                              Cannot be null.
 *  @param      nodes           The child nodes.  Can be any combination of blockquote and
 *                              non-blockquote nodes.  Cannot be null.
 */
ZSSEditor.toggleBlockquoteForSpecificChildNodes = function(parentNode, nodes) {

    if (nodes && nodes.length > 0) {
        if (parentNode.nodeName == NodeName.BLOCKQUOTE) {
            for (var counter = 0; counter < nodes.length; counter++) {
                this.turnBlockquoteOffForNode(nodes[counter]);
            }
        } else {
            
            var turnOn = (nodes[0].nodeName != NodeName.BLOCKQUOTE);
            
            for (var counter = 0; counter < nodes.length; counter++) {
                if (turnOn) {
                    this.turnBlockquoteOnForNode(nodes[counter]);
                } else {
                    this.turnBlockquoteOffForNode(nodes[counter]);
                }
            }
        }
    }
};


/**
 *  @brief      Turns blockquote off for the specified node.
 *
 *  @param      node    The node to turn the blockquote off for.  It can either be a blockquote
 *                      node (in which case it will be removed and all child nodes extracted) or
 *                      have a parent blockquote node (in which case the node will be extracted
 *                      from its parent).
 */
ZSSEditor.turnBlockquoteOffForNode = function(node) {
    
    if (node.nodeName == NodeName.BLOCKQUOTE) {
        for (var i = 0; i < node.childNodes.length; i++) {
            this.extractNodeFromAncestorNode(node.childNodes[i], node);
        }
    } else {
        if (node.parentNode.nodeName == NodeName.BLOCKQUOTE) {
            this.extractNodeFromAncestorNode(node, node.parentNode);
        }
    }
};

/**
 *  @brief      Turns blockquote on for the specified node.
 *
 *  @param      node    The node to turn blockquote on for.  Will attempt to attach the newly
 *                      created blockquote to sibling or uncle blockquote nodes.  If the node is
 *                      null or it's parent is null, this method will exit without affecting it
 *                      (this can actually be caused by this method modifying the surrounding
 *                      nodes, if those nodes are stored in an array - and thus are not notified
 *                      of DOM hierarchy changes).
 */
ZSSEditor.turnBlockquoteOnForNode = function(node) {
    
    if (!node || !node.parentNode) {
        return;
    }
    
    var couldJoinBlockquotes = this.joinAdjacentSiblingsOrAncestorBlockquotes(node);
    
    if (!couldJoinBlockquotes) {
        var blockquote = document.createElement(NodeName.BLOCKQUOTE);
        
        node.parentNode.insertBefore(blockquote, node);
        blockquote.appendChild(node);
    }
};

// MARK: - Images

ZSSEditor.updateImage = function(url, alt) {

    ZSSEditor.restoreRange();

    if (ZSSEditor.currentEditingImage) {
        var c = ZSSEditor.currentEditingImage;
        c.attr('src', url);
        c.attr('alt', alt);
    }
    ZSSEditor.sendEnabledStyles();

};

ZSSEditor.insertImage = function(url, alt) {
    var html = '<img src="'+url+'" alt="'+alt+'" />';
    
    this.insertHTML(html);
    this.sendEnabledStyles();
};

/**
 *  @brief      Inserts a local image URL.  Useful for images that need to be uploaded.
 *  @details    By inserting a local image URL, we can make sure the image is shown to the user
 *              as soon as it's selected for uploading.  Once the image is successfully uploaded
 *              the application should call replaceLocalImageWithRemoteImage().
 *
 *  @param      imageNodeIdentifier     This is a unique ID provided by the caller.  It exists as
 *                                      a mechanism to update the image node with the remote URL
 *                                      when replaceLocalImageWithRemoteImage() is called.
 *  @param      localImageUrl           The URL of the local image to display.  Please keep in mind
 *                                      that a remote URL can be used here too, since this method
 *                                      does not check for that.  It would be a mistake.
 */
ZSSEditor.insertLocalImage = function(imageNodeIdentifier, localImageUrl) {
    var progressIdentifier = this.getImageProgressIdentifier(imageNodeIdentifier);
    var imageContainerIdentifier = this.getImageContainerIdentifier(imageNodeIdentifier);
    var imgContainerStart = '<span id="' + imageContainerIdentifier+'" class="img_container">';
    var imgContainerEnd = '</span>';
    var progress = '<progress id="' + progressIdentifier+'" value=0  class="wp_media_indicator"></progress>';
    var image = '<img data-wpid="' + imageNodeIdentifier + '" src="' + localImageUrl + '" alt="" />';
    var html = imgContainerStart + progress+image + imgContainerEnd;
    
    this.insertHTML(html);
    this.sendEnabledStyles();
};

ZSSEditor.getImageNodeWithIdentifier = function(imageNodeIdentifier) {
    return $('img[data-wpid="' + imageNodeIdentifier+'"]');
};

ZSSEditor.getImageProgressIdentifier = function(imageNodeIdentifier) {
    return 'progress_' + imageNodeIdentifier;
};

ZSSEditor.getImageProgressNodeWithIdentifier = function(imageNodeIdentifier) {
    return $('#'+this.getImageProgressIdentifier(imageNodeIdentifier));
};

ZSSEditor.getImageContainerIdentifier = function(imageNodeIdentifier) {
    return 'img_container_' + imageNodeIdentifier;
};

ZSSEditor.getImageContainerNodeWithIdentifier = function(imageNodeIdentifier) {
    return $('#'+this.getImageContainerIdentifier(imageNodeIdentifier));
};

ZSSEditor.searchForMediaNode = function(nodes) {
    if (nodes === undefined) {
        return null;
    }
    for (var i = 0; i < nodes.length; i++) {
        var node = nodes[i];
        if ( ZSSEditor.isMediaContainerNode(node) ) {
            return node;
        }
        var children = node.children;
        return this.searchForMediaNode(children);
    }
    return null;
};

ZSSEditor.isMediaContainerNode = function(node) {
    if (node.id === undefined) {
        return false;
    }
    return (node.id.search("img_container_") == 0) || (node.id.search("video_container_") == 0);
};

ZSSEditor.extractMediaIdentifier = function(node) {
    if (node.id.search("img_container_") == 0) {
        return node.id.replace("img_container_", "");
    } else if (node.id.search("video_container_") == 0) {
        return node.id.replace("video_container_", "");
    }
    return "";
};

/**
 *  @brief      Replaces a local image URL with a remote image URL.  Useful for images that have
 *              just finished uploading.
 *  @details    The remote image can be available after a while, when uploading images.  This method
 *              allows for the remote URL to be loaded once the upload completes.
 *
 *  @param      imageNodeIdentifier     This is a unique ID provided by the caller.  It exists as
 *                                      a mechanism to update the image node with the remote URL
 *                                      when replaceLocalImageWithRemoteImage() is called.
 *  @param      remoteImageUrl          The URL of the remote image to display.
 *  @param      mediaID                 An integer that is the mediaID of the image on the server.
 */
ZSSEditor.replaceLocalImageWithRemoteImage = function(imageNodeIdentifier, remoteImageUrl, mediaID) {
    var imageNode = this.getImageNodeWithIdentifier(imageNodeIdentifier);
    
    if (imageNode.length == 0) {
        // even if the image is not present anymore we must do callback
        this.markImageUploadDone(imageNodeIdentifier);
        return;
    }
    
    var image = new Image;
    
    image.onload = function () {
        ZSSEditor.markImageUploadDone(imageNodeIdentifier, image, mediaID);
    }
    
    image.onerror = function () {
        // Even on an error, we swap the image for the time being.  This is because private
        // blogs are currently failing to download images due to access privilege issues.
        //
        ZSSEditor.markImageUploadDone(imageNodeIdentifier, image, mediaID);
    }
    
    image.src = remoteImageUrl;
};

/**
 *  @brief      Update the progress indicator for the image identified with the value in progress.
 *
 *  @param      imageNodeIdentifier This is a unique ID provided by the caller.
 *  @param      progress    A value between 0 and 1 indicating the progress on the image.
 */
ZSSEditor.setProgressOnImage = function(imageNodeIdentifier, progress) {
    var imageNode = this.getImageNodeWithIdentifier(imageNodeIdentifier);
    if (imageNode.length == 0){
        return;
    }
    if (progress < 1){
        imageNode.addClass("uploading");
    }
    
    var imageProgressNode = this.getImageProgressNodeWithIdentifier(imageNodeIdentifier);
    if (imageProgressNode.length == 0){
          return;
    }
    imageProgressNode.attr("value",progress);
};

/**
 *  @brief      Notifies that the image upload as finished
 *
 *  @param      imageNodeIdentifier     The unique image ID for the uploaded image
 *  @param      image  The image to be replaces
 *  @param      mediaID An integer that is the mediaID of the image on the server
 */
ZSSEditor.markImageUploadDone = function(imageNodeIdentifier, image, mediaID) {
    var imageNode = this.getImageNodeWithIdentifier(imageNodeIdentifier);
    if (imageNode.length > 0){
        // remove identifier attributed from image
        imageNode.removeAttr('data-wpid');
        
        // remove uploading style
        imageNode.removeClass("uploading");
        imageNode.removeAttr("class");

        // set remote source
        imageNode.attr('src', image.src);
        // set attributes
        imageNode.attr({'width':image.width, 'height':image.height, 'class':'alignnone size-full'});
        if (mediaID >= 0) {
            imageNode.addClass('wp-image-' + mediaID);
        }

        // Remove all extra formatting nodes for progress
        if (imageNode.parent().attr("id") == this.getImageContainerIdentifier(imageNodeIdentifier)) {
            // remove id from container to avoid to report a user removal
            imageNode.parent().attr("id", "");
            imageNode.parent().replaceWith(imageNode);
        }
        // Wrap link around image
        var linkTag = '<a href="' + imageNode.attr("src") + '"></a>';
        imageNode.wrap(linkTag);
    }
    
    var joinedArguments = ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments();
    ZSSEditor.callback("callback-input", joinedArguments);
    // We invoke the sendImageReplacedCallback with a delay to avoid for
    // it to be ignored by the webview because of the previous callback being done.
    var thisObj = this;
    setTimeout(function() { thisObj.sendImageReplacedCallback(imageNodeIdentifier);}, 500);
};

/**
 *  @brief      Callbacks to native that the image upload as finished and the local url was replaced by the remote url
 *
 *  @param      imageNodeIdentifier     The unique image ID for the uploaded image
 */
ZSSEditor.sendImageReplacedCallback = function( imageNodeIdentifier ) {
    var arguments = ['id=' + encodeURIComponent( imageNodeIdentifier )];
    
    var joinedArguments = arguments.join( defaultCallbackSeparator );
    
    this.callback("callback-image-replaced", joinedArguments);
};

/**
 *  @brief      Marks the image as failed to upload
 *
 *  @param      imageNodeIdentifier     This is a unique ID provided by the caller.
 *  @param      message                 A message to show to the user, overlayed on the image
 */
ZSSEditor.markImageUploadFailed = function(imageNodeIdentifier, message) {
    var imageNode = this.getImageNodeWithIdentifier(imageNodeIdentifier);
    if (imageNode.length == 0){
        return;
    }

    var sizeClass = '';
    if ( imageNode[0].width > 480 && imageNode[0].height > 240 ) {
        sizeClass = "largeFail";
    } else if ( imageNode[0].width < 100 || imageNode[0].height < 100 ) {
        sizeClass = "smallFail";
    }
    
    imageNode.addClass('failed');
    
    var imageContainerNode = this.getImageContainerNodeWithIdentifier(imageNodeIdentifier);
    if(imageContainerNode.length != 0){
        imageContainerNode.attr("data-failed", message);
        imageNode.removeClass("uploading");
        imageContainerNode.addClass('failed');
        imageContainerNode.addClass(sizeClass);
    }
    
    var imageProgressNode = this.getImageProgressNodeWithIdentifier(imageNodeIdentifier);
    if (imageProgressNode.length != 0){
        imageProgressNode.addClass('failed');
    }
};

/**
 *  @brief      Unmarks the image as failed to upload
 *
 *  @param      imageNodeIdentifier     This is a unique ID provided by the caller.
 */
ZSSEditor.unmarkImageUploadFailed = function(imageNodeIdentifier, message) {
    var imageNode = this.getImageNodeWithIdentifier(imageNodeIdentifier);
    if (imageNode.length != 0){
        imageNode.removeClass('failed');
    }
    
    var imageContainerNode = this.getImageContainerNodeWithIdentifier(imageNodeIdentifier);
    if(imageContainerNode.length != 0){
        imageContainerNode.removeAttr("data-failed");
        imageContainerNode.removeClass('failed');
    }
    
    var imageProgressNode = this.getImageProgressNodeWithIdentifier(imageNodeIdentifier);
    if (imageProgressNode.length != 0){
        imageProgressNode.removeClass('failed');
    }
};

/**
 *  @brief      Remove the image from the DOM.
 *
 *  @param      imageNodeIdentifier     This is a unique ID provided by the caller.
 */
ZSSEditor.removeImage = function(imageNodeIdentifier) {
    var imageNode = this.getImageNodeWithIdentifier(imageNodeIdentifier);
    if (imageNode.length != 0){
        imageNode.remove();
    }
    // if image is inside options container we need to remove the container
    var imageContainerNode = this.getImageContainerNodeWithIdentifier(imageNodeIdentifier);
    if (imageContainerNode.length != 0){
        //reset id before removal to avoid detection of user removal
        imageContainerNode.attr("id","");
        imageContainerNode.remove();
    }
};

/**
 *  @brief      Callbacks to native that the media container was deleted by the user
 *
 *  @param      mediaNodeIdentifier     The unique media ID
 */
ZSSEditor.sendMediaRemovedCallback = function(mediaNodeIdentifier) {
    var arguments = ['id=' + encodeURIComponent(mediaNodeIdentifier)];
    var joinedArguments = arguments.join(defaultCallbackSeparator);
    this.callback("callback-media-removed", joinedArguments);
};

/**
 *  @brief Inserts a video tag using the videoURL as source and posterURL as the 
 *  image to show while video is loading.
 *
 *  @param videoURL  the url of the video to present
 *  @param posterURL the url of an image to show while the video is loading
 *  @param alt       the alt description when the video is not supported.
 *
 */
ZSSEditor.insertVideo = function(videoURL, posterURL, alt) {
    var zeroWidthSpace = '&#x200b;';
    var html = zeroWidthSpace + '<video controls webkit-playsinline poster="' + posterURL+ '"><source src="'
    + videoURL + '" type="video/mp4"/>' + alt + '</video>' + zeroWidthSpace;
    
    this.insertHTML(html);
    this.sendEnabledStyles();
};

/**
 *  @brief      Inserts a video tag marked with a identifier using only a poster image.  Useful for videos that need to be uploaded.
 *  @details    By inserting a video with only a porter URL, we can make sure the video element is shown to the user
 *              as soon as it's selected for uploading.  Once the video is successfully uploaded
 *              the application should call replaceLocalVideoWithRemoteVideo().
 *
 *  @param      videoNodeIdentifier     This is a unique ID provided by the caller.  It exists as
 *                                      a mechanism to update the video node with the remote URL
 *                                      when replaceLocalVideoWithRemoteVideo() is called.
 *  @param      posterURL               The URL of a poster image to display while the video is being uploaded.
 */
ZSSEditor.insertInProgressVideoWithIDUsingPosterImage = function(videoNodeIdentifier, posterURL) {
    var zeroWidthSpace = '&#x200b;';
    var progressIdentifier = this.getVideoProgressIdentifier(videoNodeIdentifier);
    var videoContainerIdentifier = this.getVideoContainerIdentifier(videoNodeIdentifier);
    var videoContainerStart = '<span id="' + videoContainerIdentifier + '" class="video_container">';
    var videoContainerEnd = '</span>';
    var progress = '<progress id="' + progressIdentifier + '" value=0 class="wp_media_indicator"></progress>';
    var video = '<video data-wpid="' + videoNodeIdentifier + '" webkit-playsinline poster="' + posterURL + '" onclick="" class="uploading"></video>';
    var html =  zeroWidthSpace + videoContainerStart + progress + video + videoContainerEnd + zeroWidthSpace;
    this.insertHTML(html);
    this.sendEnabledStyles();
};

ZSSEditor.getVideoNodeWithIdentifier = function(videoNodeIdentifier) {
    return $('video[data-wpid="' + videoNodeIdentifier+'"]');
};

ZSSEditor.getVideoProgressIdentifier = function(videoNodeIdentifier) {
    return 'progress_' + videoNodeIdentifier;
};

ZSSEditor.getVideoProgressNodeWithIdentifier = function(videoNodeIdentifier) {
    return $('#'+this.getVideoProgressIdentifier(videoNodeIdentifier));
};

ZSSEditor.getVideoContainerIdentifier = function(videoNodeIdentifier) {
    return 'video_container_' + videoNodeIdentifier;
};

ZSSEditor.getVideoContainerNodeWithIdentifier = function(videoNodeIdentifier) {
    return $('#'+this.getVideoContainerIdentifier(videoNodeIdentifier));
};


/**
 *  @brief      Replaces a local Video URL with a remote Video URL.  Useful for videos that have
 *              just finished uploading.
 *  @details    The remote Video can be available after a while, when uploading Videos.  This method
 *              allows for the remote URL to be loaded once the upload completes.
 *
 *  @param      videoNodeIdentifier     This is a unique ID provided by the caller.  It exists as
 *                                      a mechanism to update the Video node with the remote URL
 *                                      when replaceLocalVideoWithRemoteVideo() is called.
 *  @param      remoteVideoUrl          The URL of the remote Video to display.
 *  @param      remotePosterUrl         The URL of thre remote poster image to display
 *  @param      videopressID          VideoPress Guid of the video if any
 */
ZSSEditor.replaceLocalVideoWithRemoteVideo = function(videoNodeIdentifier, remoteVideoUrl, remotePosterUrl, videopressID) {
    var videoNode = this.getVideoNodeWithIdentifier(videoNodeIdentifier);
    
    if (videoNode.length == 0) {
        // even if the Video is not present anymore we must do callback
        this.markVideoUploadDone(videoNodeIdentifier);
        return;
    }
    videoNode.attr('src', remoteVideoUrl);
    videoNode.attr('controls', '');
    videoNode.attr('preload', 'metadata');
    if (videopressID != '') {
        videoNode.attr('data-wpvideopress', videopressID);
    }
    videoNode.attr('poster', remotePosterUrl);
    var thisObj = this;
    videoNode.on('webkitbeginfullscreen', function (event){ thisObj.sendVideoFullScreenStarted(); } );
    videoNode.on('webkitendfullscreen', function (event){ thisObj.sendVideoFullScreenEnded(); } );
    videoNode.on('error', function(event) { videoNode.load()} );
    this.markVideoUploadDone(videoNodeIdentifier);
};

/**
 *  @brief      Update the progress indicator for the Video identified with the value in progress.
 *
 *  @param      VideoNodeIdentifier This is a unique ID provided by the caller.
 *  @param      progress    A value between 0 and 1 indicating the progress on the Video.
 */
ZSSEditor.setProgressOnVideo = function(videoNodeIdentifier, progress) {
    var videoNode = this.getVideoNodeWithIdentifier(videoNodeIdentifier);
    if (videoNode.length == 0){
        return;
    }
    if (progress < 1){
        videoNode.addClass("uploading");
    }
    
    var videoProgressNode = this.getVideoProgressNodeWithIdentifier(videoNodeIdentifier);
    if (videoProgressNode.length == 0){
        return;
    }
    videoProgressNode.attr("value",progress);
};

/**
 *  @brief      Notifies that the Video upload as finished
 *
 *  @param      VideoNodeIdentifier     The unique Video ID for the uploaded Video
 */
ZSSEditor.markVideoUploadDone = function(videoNodeIdentifier) {
    var videoNode = this.getVideoNodeWithIdentifier(videoNodeIdentifier);
    if (videoNode.length > 0) {
        
        // remove identifier attributed from Video
        videoNode.removeAttr('data-wpid');
        
        // remove uploading style
        videoNode.removeClass("uploading");
        videoNode.removeAttr("class");
        
        // Remove all extra formatting nodes for progress
        if (videoNode.parent().attr("id") == this.getVideoContainerIdentifier(videoNodeIdentifier)) {
            // remove id from container to avoid to report a user removal
            videoNode.parent().attr("id", "");
            videoNode.parent().replaceWith(videoNode);
        }
    }
    var joinedArguments = ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments();
    ZSSEditor.callback("callback-input", joinedArguments);
    // We invoke the sendVideoReplacedCallback with a delay to avoid for
    // it to be ignored by the webview because of the previous callback being done.
    var thisObj = this;
    setTimeout(function() { thisObj.sendVideoReplacedCallback(videoNodeIdentifier);}, 500);
};

/**
 *  @brief      Callbacks to native that the video upload as finished and the local url was replaced by the remote url
 *
 *  @param      videoNodeIdentifier    the unique video ID for the uploaded Video
 */
ZSSEditor.sendVideoReplacedCallback = function( videoNodeIdentifier ) {
    var arguments = ['id=' + encodeURIComponent( videoNodeIdentifier )];
    
    var joinedArguments = arguments.join( defaultCallbackSeparator );
    
    this.callback("callback-video-replaced", joinedArguments);
};

/**
 *  @brief      Callbacks to native that the video entered full screen mode
 *
 */
ZSSEditor.sendVideoFullScreenStarted = function() {
    this.callback("callback-video-fullscreen-started", "empty");
};

/**
 *  @brief      Callbacks to native that the video entered full screen mode
 *
 */
ZSSEditor.sendVideoFullScreenEnded = function() {
    this.callback("callback-video-fullscreen-ended", "empty");
};

/**
 *  @brief      Callbacks to native that the video upload as finished and the local url was replaced by the remote url
 *
 *  @param      videoNodeIdentifier    the unique video ID for the uploaded Video
 */
ZSSEditor.sendVideoPressInfoRequest = function( videoPressID ) {
    var arguments = ['id=' + encodeURIComponent( videoPressID )];
    
    var joinedArguments = arguments.join( defaultCallbackSeparator );
    
    this.callback("callback-videopress-info-request", joinedArguments);
};


/**
 *  @brief      Marks the Video as failed to upload
 *
 *  @param      VideoNodeIdentifier     This is a unique ID provided by the caller.
 *  @param      message                 A message to show to the user, overlayed on the Video
 */
ZSSEditor.markVideoUploadFailed = function(videoNodeIdentifier, message) {
    var videoNode = this.getVideoNodeWithIdentifier(videoNodeIdentifier);
    if (videoNode.length == 0){
        return;
    }
    
    var sizeClass = '';
    if ( videoNode[0].width > 480 && videoNode[0].height > 240 ) {
        sizeClass = "largeFail";
    } else if ( videoNode[0].width < 100 || videoNode[0].height < 100 ) {
        sizeClass = "smallFail";
    }
    
    videoNode.addClass('failed');
    
    var videoContainerNode = this.getVideoContainerNodeWithIdentifier(videoNodeIdentifier);
    if(videoContainerNode.length != 0){
        videoContainerNode.attr("data-failed", message);
        videoNode.removeClass("uploading");
        videoContainerNode.addClass('failed');
        videoContainerNode.addClass(sizeClass);
    }
    
    var videoProgressNode = this.getVideoProgressNodeWithIdentifier(videoNodeIdentifier);
    if (videoProgressNode.length != 0){
        videoProgressNode.addClass('failed');
    }
};

/**
 *  @brief      Unmarks the Video as failed to upload
 *
 *  @param      VideoNodeIdentifier     This is a unique ID provided by the caller.
 */
ZSSEditor.unmarkVideoUploadFailed = function(videoNodeIdentifier, message) {
    var videoNode = this.getVideoNodeWithIdentifier(videoNodeIdentifier);
    if (videoNode.length != 0){
        videoNode.removeClass('failed');
    }
    
    var videoContainerNode = this.getVideoContainerNodeWithIdentifier(videoNodeIdentifier);
    if(videoContainerNode.length != 0){
        videoContainerNode.removeAttr("data-failed");
        videoContainerNode.removeClass('failed');
    }
    
    var videoProgressNode = this.getVideoProgressNodeWithIdentifier(videoNodeIdentifier);
    if (videoProgressNode.length != 0){
        videoProgressNode.removeClass('failed');
    }
};

/**
 *  @brief      Remove the Video from the DOM.
 *
 *  @param      videoNodeIdentifier     This is a unique ID provided by the caller.
 */
ZSSEditor.removeVideo = function(videoNodeIdentifier) {
    var videoNode = this.getVideoNodeWithIdentifier(videoNodeIdentifier);
    if (videoNode.length != 0){
        videoNode.remove();
    }
    
    // if Video is inside options container we need to remove the container
    var videoContainerNode = this.getVideoContainerNodeWithIdentifier(videoNodeIdentifier);
    if (videoContainerNode.length != 0){
        //reset id before removal to avoid detection of user removal
        videoContainerNode.attr("id","");
        videoContainerNode.remove();
    }
};

ZSSEditor.replaceVideoPressVideosForShortcode = function ( html) {
    // call methods to restore any transformed content from its visual presentation to its source code.
    var regex = /<video[^>]*data-wpvideopress="([\s\S]+?)"[^>]*>*<\/video>/g;
    var str = html.replace( regex, ZSSEditor.removeVideoVisualFormattingCallback );

    return str;
}

ZSSEditor.removeVideoVisualFormattingCallback = function( match, content ) {
    return "[wpvideo " + content + "]";
}

ZSSEditor.applyVideoFormattingCallback = function( match ) {    
    if (match.attrs.numeric.length == 0) {
        return match.content;
    }
    var videopressID = match.attrs.numeric[0];
    var posterSVG = '"wpposter.svg"';
    // The empty 'onclick' is important. It prevents the cursor jumping to the end
    // of the content body when `-webkit-user-select: none` is set and the video is tapped.
    var out = '<video data-wpvideopress="' + videopressID + '" webkit-playsinline src="videopress.mp4" preload="metadata" poster=' + posterSVG +' onclick="" onerror="ZSSEditor.sendVideoPressInfoRequest(\'' + videopressID +'\');"></video>';
    
    return out;
}

/**
 *  @brief      Sets the VidoPress video URL and poster URL on a video tag.
 *  @details    When switching between source and visual the wpvideo shortcode are replace by a video tag. Unfortunaly there 
 *              is no way to infer the video url from the shortcode so we need to find this information and then set it on the video tag.
 *
 *  @param      videopressID      videopress identifier of the video.
 *  @param      videoURL          URL of the video file to display.
 *  @param      posterURL         URL of the poster image to display
 */
ZSSEditor.setVideoPressLinks = function(videopressID, videoURL, posterURL ) {
    var videoNode = $('video[data-wpvideopress="' + videopressID+'"]');
    if (videoNode.length == 0) {
        return;
    }
    videoNode.attr('src', videoURL);
    videoNode.attr('controls', '');
    if (posterURL.length == 0) {
        videoNode.attr('poster', 'wpposter.svg');
    } else {
        videoNode.attr('poster', posterURL);
    }
    var thisObj = this;
    videoNode.on('webkitbeginfullscreen', function (event){ thisObj.sendVideoFullScreenStarted(); } );
    videoNode.on('webkitendfullscreen', function (event){ thisObj.sendVideoFullScreenEnded(); } );
    videoNode.load();
};

/**
 *  @brief  Stops all video of playing
 *
 */
ZSSEditor.pauseAllVideos = function () {
    $('video').each(function() {
        this.pause();
    });
}

/**
 *  @brief      Updates the currently selected image, replacing its markup with
 *  new markup based on the specified meta data string.
 *
 *  @param      imageMetaString   A JSON string representing the updated meta data.
 */
ZSSEditor.updateCurrentImageMeta = function( imageMetaString ) {
    if ( !ZSSEditor.currentEditingImage ) {
        return;
    }

    var imageMeta = JSON.parse( imageMetaString );
    var html = ZSSEditor.createImageFromMeta( imageMeta );

    // Insert the updated html and remove the outdated node.
    // This approach is preferred to selecting the current node via a range,
    // and then replacing it when calling insertHTML. The insertHTML call can,
    // in certain cases, modify the current and inserted markup depending on what
    // elements surround the targeted node.  This approach is safer.
    var node = ZSSEditor.findImageCaptionNode( ZSSEditor.currentEditingImage );
    node.insertAdjacentHTML( 'afterend', html );
    node.remove();

    ZSSEditor.currentEditingImage = null;
}

ZSSEditor.applyImageSelectionFormatting = function( imageNode ) {
    var node = ZSSEditor.findImageCaptionNode( imageNode );

    var sizeClass = "";
    if ( imageNode.width < 100 || imageNode.height < 100 ) {
        sizeClass = " small";
    }

    var overlay = '<span class="edit-overlay"><span class="edit-content">' + this.localizedEditText + '</span></span>';
    var html = '<span class="edit-container' + sizeClass + '">' + overlay + '</span>';
   	node.insertAdjacentHTML( 'beforebegin', html );
    var selectionNode = node.previousSibling;
    selectionNode.appendChild( node );
}

ZSSEditor.removeImageSelectionFormatting = function( imageNode ) {
    var node = ZSSEditor.findImageCaptionNode( imageNode );
    if ( !node.parentNode || node.parentNode.className.indexOf( "edit-container" ) == -1 ) {
        return;
    }

    var parentNode = node.parentNode;
    var container = parentNode.parentNode;
    container.insertBefore( node, parentNode );
    parentNode.remove();
}

ZSSEditor.removeImageSelectionFormattingFromHTML = function( html ) {
    var tmp = document.createElement( "div" );
    var tmpDom = $( tmp ).html( html );

    var matches = tmpDom.find( "span.edit-container img" );
    if ( matches.length == 0 ) {
        return html;
    }

    for ( var i = 0; i < matches.length; i++ ) {
        ZSSEditor.removeImageSelectionFormatting( matches[i] );
    }

    return tmpDom.html();
}

/**
 *  @brief       Finds all related caption nodes for the specified image node.
 *
 *  @param      imageNode   An image node in the DOM to inspect.
 */
ZSSEditor.findImageCaptionNode = function( imageNode ) {
    var node = imageNode;
    if ( node.parentNode && node.parentNode.nodeName === 'A' ) {
        node = node.parentNode;
    }

    if ( node.parentNode && node.parentNode.className.indexOf( 'wp-caption' ) != -1 ) {
        node = node.parentNode;
    }

    if ( node.parentNode && (node.parentNode.className.indexOf( 'wp-temp' ) != -1 ) ) {
        node = node.parentNode;
    }

    return node;
}

/**
 *  Modified from wp-includes/js/media-editor.js
 *  see `image`
 *
 *  @brief      Construct html markup for an image, and optionally a link an caption shortcode.
 *
 *  @param      props   A dictionary of properties used to compose the markup. See comments in extractImageMeta.
 *
 *  @return     Returns the html mark up as a string
 */
ZSSEditor.createImageFromMeta = function( props ) {
    var img = {},
    options, classes, shortcode, html;

    classes = props.classes || [];
    if ( ! ( classes instanceof Array ) ) {
        classes = classes.split( ' ' );
    }

    _.extend( img, _.pick( props, 'width', 'height', 'alt', 'src', 'title' ) );

    // Only assign the align class to the image if we're not printing
    // a caption, since the alignment is sent to the shortcode.
    if ( props.align && ! props.caption ) {
        classes.push( 'align' + props.align );
    }

    if ( props.size ) {
        classes.push( 'size-' + props.size );
    }

    if ( props.attachment_id ) {
        classes.push( 'wp-image-' + props.attachment_id );
    }

    img['class'] = _.compact( classes ).join(' ');

    // Generate `img` tag options.
    options = {
        tag:    'img',
        attrs:  img,
        single: true
    };

    // Generate the `a` element options, if they exist.
    if ( props.linkUrl ) {
        options = {
            tag:   'a',
            attrs: {
                href: props.linkUrl
            },
            content: options
        };

        if ( props.linkClassName ) {
            options.attrs.class = props.linkClassName;
        }

        if ( props.linkRel ) {
            options.attrs.rel = props.linkRel;
        }

        if ( props.linkTargetBlank ) { // expects a boolean
            options.attrs.target = "_blank";
        }
    }

    html = wp.html.string( options );

    // Generate the caption shortcode.
    if ( props.caption ) {
        shortcode = {};

        if ( img.width ) {
            shortcode.width = img.width;
        }

        if ( props.captionId ) {
            shortcode.id = props.captionId;
        }

        if ( props.align ) {
            shortcode.align = 'align' + props.align;
        } else {
            shortcode.align = 'alignnone';
        }

        if (props.captionClassName) {
            shortcode.class = props.captionClassName;
        }

        html = wp.shortcode.string({
            tag:     'caption',
            attrs:   shortcode,
            content: html + ' ' + props.caption
        });

        html = ZSSEditor.applyVisualFormatting( html );
    }

    return html;
};

/**
 *  Modified from wp-includes/js/tinymce/plugins/wpeditimage/plugin.js
 *  see `extractImageData`
 *
 *  @brief      Extracts properties and meta data from an image, and optionally its link and caption.
 *
 *  @param      imageNode   An image node in the DOM to inspect.
 *
 *  @return     Returns an object containing the extracted properties and meta data.
 */
ZSSEditor.extractImageMeta = function( imageNode ) {
    var classes, extraClasses, metadata, captionBlock, caption, link, width, height,
    captionClassName = [],
    isIntRegExp = /^\d+$/;

    // Default attributes. All values are strings, except linkTargetBlank
    metadata = {
        align: 'none',      // Accepted values: center, left, right or empty string.
        alt: '',            // Image alt attribute
        attachment_id: '',  // Numeric attachment id of the image in the site's media library
        caption: '',        // The text of the caption for the image (if any)
        captionClassName: '', // The classes for the caption shortcode (if any).
        captionId: '',      // The caption shortcode's ID attribute. The numeric value should match the value of attachment_id
        classes: '',        // The class attribute for the image. Does not include editor generated classes
        height: '',         // The image height attribute
        linkClassName: '',  // The class attribute for the link
        linkRel: '',        // The rel attribute for the link (if any)
        linkTargetBlank: false, // true if the link should open in a new window.
        linkUrl: '',        // The href attribute of the link
        size: 'custom',     // Accepted values: custom, medium, large, thumbnail, or empty string
        src: '',            // The src attribute of the image
        title: '',          // The title attribute of the image (if any)
        width: '',          // The image width attribute
        naturalWidth:'',    // The natural width of the image.
        naturalHeight:''    // The natural height of the image.
    };

    // populate metadata with values of matched attributes
    metadata.src = $( imageNode ).attr( 'src' ) || '';
    metadata.alt = $( imageNode ).attr( 'alt' ) || '';
    metadata.title = $( imageNode ).attr( 'title' ) || '';
    metadata.naturalWidth = imageNode.naturalWidth;
    metadata.naturalHeight = imageNode.naturalHeight;

    width = $(imageNode).attr( 'width' );
    height = $(imageNode).attr( 'height' );

    if ( ! isIntRegExp.test( width ) || parseInt( width, 10 ) < 1 ) {
        width = imageNode.naturalWidth || imageNode.width;
    }

    if ( ! isIntRegExp.test( height ) || parseInt( height, 10 ) < 1 ) {
        height = imageNode.naturalHeight || imageNode.height;
    }

    metadata.width = width;
    metadata.height = height;

    classes = imageNode.className.split( /\s+/ );
    extraClasses = [];

    $.each( classes, function( index, value ) {
        if ( /^wp-image/.test( value ) ) {
           metadata.attachment_id = parseInt( value.replace( 'wp-image-', '' ), 10 );
        } else if ( /^align/.test( value ) ) {
           metadata.align = value.replace( 'align', '' );
        } else if ( /^size/.test( value ) ) {
           metadata.size = value.replace( 'size-', '' );
        } else {
           extraClasses.push( value );
        }
    } );

    metadata.classes = extraClasses.join( ' ' );

    // Extract caption
    var captionMeta = ZSSEditor.captionMetaForImage( imageNode )
    metadata = $.extend( metadata, captionMeta );

    // Extract linkTo
    if ( imageNode.parentNode && imageNode.parentNode.nodeName === 'A' ) {
        link = imageNode.parentNode;
        metadata.linkClassName = link.className;
        metadata.linkRel = $( link ).attr( 'rel' ) || '';
        metadata.linkTargetBlank = $( link ).attr( 'target' ) === '_blank' ? true : false;
        metadata.linkUrl = $( link ).attr( 'href' ) || '';
    }

    return metadata;
};

/**
 *  @brief      Extracts the caption shortcode for an image.
 *
 *  @param      imageNode   An image node in the DOM to inspect.
 *
 *  @return     Returns a shortcode match (if any) for the passed image node.
 *  See shortcode.js::next for details
 */
ZSSEditor.getCaptionForImage = function( imageNode ) {
    var node = ZSSEditor.findImageCaptionNode( imageNode );

    // Ensure we're working with the formatted caption
    if ( node.className.indexOf( 'wp-temp' ) == -1 ) {
        return;
    }

    var html = node.outerHTML;
    html = ZSSEditor.removeVisualFormatting( html );

    return wp.shortcode.next( "caption", html, 0 );
};

/**
 *  @brief      Extracts meta data for the caption (if any) for the passed image node.
 *
 *  @param      imageNode   An image node in the DOM to inspect.
 *
 *  @return     Returns an object containing the extracted meta data.
 *  See shortcode.js::next or details
 */
ZSSEditor.captionMetaForImage = function( imageNode ) {
    var attrs,
        meta = {
            align:  '',
            caption: '',
            captionClassName: '',
            captionId: ''
        };

    var caption = ZSSEditor.getCaptionForImage( imageNode );
    if ( !caption ) {
        // don return align
        meta = {
            caption: '',
            captionClassName: '',
            captionId: ''
        };
        return meta;
    }

    attrs = caption.shortcode.attrs.named;
    if ( attrs.align ) {
        meta.align = attrs.align.replace( 'align', '' );
    }
    if ( attrs.class ) {
        meta.captionClassName = attrs.class;
    }
    if ( attrs.id ) {
        meta.captionId = attrs.id;
    }
    meta.caption = caption.shortcode.content.substr( caption.shortcode.content.lastIndexOf( ">" ) + 1 );

    return meta;
}

/**
 *  @brief      Adds visual formatting to a caption shortcodes.
 *
 *  @param      html   The markup containing caption shortcodes to process.
 *
 *  @return     The html with caption shortcodes replaced with editor specific markup.
 *  See shortcode.js::next or details
 */
ZSSEditor.applyCaptionFormatting = function( match ) {
    var attrs = match.attrs.named;
    // The empty 'onclick' is important. It prevents the cursor jumping to the end
    // of the content body when `-webkit-user-select: none` is set and the caption is tapped.
    var out = '<label class="wp-temp" data-wp-temp="caption" contenteditable="false" onclick="">';
    out += '<span class="wp-caption"';

    if ( attrs.width ) {
        out += ' style="width:' + attrs.width + 'px; max-width:100% !important;"';
    }
    $.each( attrs, function( key, value ) {
        out += " data-caption-" + key + '="' + value + '"';
    } );

    out += '>';
    out += match.content;
    out += '</span>';
    out += '</label>';

    return out;
}

/**
 *  @brief      Removes custom visual formatting for caption shortcodes.
 *
 *  @param      html   The markup to process
 *
 *  @return     The html with formatted captions restored to the original shortcode markup.
 */
ZSSEditor.removeCaptionFormatting = function( html ) {
    // call methods to restore any transformed content from its visual presentation to its source code.
    var regex = /<label class="wp-temp" data-wp-temp="caption"[^>]*>([\s\S]+?)<\/label>/g;

    var str = html.replace( regex, ZSSEditor.removeCaptionFormattingCallback );

    return str;
}

ZSSEditor.removeCaptionFormattingCallback = function( match, content ) {
    // TODO: check is a visual temp node
    var out = '';

    if ( content.indexOf('<img ') === -1 ) {
        // Broken caption. The user managed to drag the image out?
        // Try to return the caption text as a paragraph.
        out = content.match( /\s*<span [^>]*>([\s\S]+?)<\/span>/gi );

        if ( out && out[1] ) {
            return '<p>' + out[1] + '</p>';
        }

        return '';
    }

    out = content.replace( /\s*<span ([^>]*)>([\s\S]+?)<\/span>/gi, function( ignoreMatch, attrStr, content ) {
        if ( ! content ) {
            return '';
        }

        var id, classes, align, width, attrs = {};

        width = attrStr.match( /data-caption-width="([0-9]*)"/ );
        width = ( width && width[1] ) ? width[1] : '';
        if ( width ) {
            attrs.width = width;
        }

        id = attrStr.match( /data-caption-id="([^"]*)"/ );
        id = ( id && id[1] ) ? id[1] : '';
        if ( id ) {
            attrs.id = id;
        }

        classes = attrStr.match( /data-caption-class="([^"]*)"/ );
        classes = ( classes && classes[1] ) ? classes[1] : '';
        if ( classes ) {
            attrs.class = classes;
        }

        align = attrStr.match( /data-caption-align="([^"]*)"/ );
        align = ( align && align[1] ) ? align[1] : '';
        if ( align ) {
            attrs.align = align;
        }

        var options = {
            'tag':'caption',
            'attrs':attrs,
            'type':'closed',
            'content':content
        };

        return wp.shortcode.string( options );
    });

    return out;
}

// MARK: - Commands

/**
 *  @brief      Applies editor specific visual formatting.
 *
 *  @param      html   The markup to format
 *
 *  @return     Returns the string with the visual formatting applied.
 */
ZSSEditor.applyVisualFormatting = function( html ) {
    var str = wp.shortcode.replace( 'caption', html, ZSSEditor.applyCaptionFormatting );
    str = wp.shortcode.replace( 'wpvideo', str, ZSSEditor.applyVideoFormattingCallback );
    return str;
}

/**
 *  @brief      Removes editor specific visual formatting
 *
 *  @param      html   The markup to remove formatting
 *
 *  @return     Returns the string with the visual formatting removed.
 */
ZSSEditor.removeVisualFormatting = function( html ) {
    var str = html;
    str = ZSSEditor.removeImageSelectionFormattingFromHTML( str );
    str = ZSSEditor.removeCaptionFormatting( str );
    str = ZSSEditor.replaceVideoPressVideosForShortcode( str );
    return str;
}

ZSSEditor.insertHTML = function(html) {

    var currentField = this.getFocusedField();
    
    if (currentField.isMultiline()) {
        // When inserting HTML in the editor (like media), we must make sure the caret is wrapped in a
        // paragraph tag.  By forcing to have all content inside paragraphs we obtain a behavior that's
        // much closer to the one we have in our web editor.
        //
        currentField.wrapCaretInParagraphIfNecessary();
    }
    
	document.execCommand('insertHTML', false, html);
	this.sendEnabledStyles();
};

ZSSEditor.isCommandEnabled = function(commandName) {
	return document.queryCommandState(commandName);
};

ZSSEditor.sendEnabledStyles = function(e) {

	var items = [];
	
    var focusedField = this.getFocusedField();
    
    if (focusedField && !focusedField.hasNoStyle) {
        // Find all relevant parent tags
        var parentTags = ZSSEditor.parentTags();
        
        for (var i = 0; i < parentTags.length; i++) {
            var currentNode = parentTags[i];
            
            if (currentNode.nodeName.toLowerCase() == 'a') {
                ZSSEditor.currentEditingLink = currentNode;
                
                var title = encodeURIComponent(currentNode.text);
                var href = encodeURIComponent(currentNode.href);
                
                items.push('link-title:' + title);
                items.push('link:' + href);
            } else if (currentNode.nodeName == NodeName.BLOCKQUOTE) {
                items.push('blockquote');
            }
        }
        
        if (ZSSEditor.isCommandEnabled('bold')) {
            items.push('bold');
        }
        if (ZSSEditor.isCommandEnabled('createLink')) {
            items.push('createLink');
        }
        if (ZSSEditor.isCommandEnabled('italic')) {
            items.push('italic');
        }
        if (ZSSEditor.isCommandEnabled('subscript')) {
            items.push('subscript');
        }
        if (ZSSEditor.isCommandEnabled('superscript')) {
            items.push('superscript');
        }
        if (ZSSEditor.isCommandEnabled('strikeThrough')) {
            items.push('strikeThrough');
        }
        if (ZSSEditor.isCommandEnabled('underline')) {
            var isUnderlined = false;
            
            // DRM: 'underline' gets highlighted if it's inside of a link... so we need a special test
            // in that case.
            if (!ZSSEditor.currentEditingLink) {
                items.push('underline');
            }
        }
        if (ZSSEditor.isCommandEnabled('insertOrderedList')) {
            items.push('orderedList');
        }
        if (ZSSEditor.isCommandEnabled('insertUnorderedList')) {
            items.push('unorderedList');
        }
        if (ZSSEditor.isCommandEnabled('justifyCenter')) {
            items.push('justifyCenter');
        }
        if (ZSSEditor.isCommandEnabled('justifyFull')) {
            items.push('justifyFull');
        }
        if (ZSSEditor.isCommandEnabled('justifyLeft')) {
            items.push('justifyLeft');
        }
        if (ZSSEditor.isCommandEnabled('justifyRight')) {
            items.push('justifyRight');
        }
        if (ZSSEditor.isCommandEnabled('insertHorizontalRule')) {
            items.push('horizontalRule');
        }
        var formatBlock = document.queryCommandValue('formatBlock');
        if (formatBlock.length > 0) {
            items.push(formatBlock);
        }
        
        // Use jQuery to figure out those that are not supported
        if (typeof(e) != "undefined") {
            
            // The target element
            var t = $(e.target);
            var nodeName = e.target.nodeName.toLowerCase();
            
            // Background Color
            try
            {
                var bgColor = t.css('backgroundColor');
                if (bgColor && bgColor.length != 0 && bgColor != 'rgba(0, 0, 0, 0)' && bgColor != 'rgb(0, 0, 0)' && bgColor != 'transparent') {
                    items.push('backgroundColor');
                }
            }
            catch(e)
            {
                // DRM: I had to add these stupid try-catch blocks to solve an issue with t.css throwing
                // exceptions for no reason.
            }
            
            // Text Color
            try
            {
                var textColor = t.css('color');
                if (textColor && textColor.length != 0 && textColor != 'rgba(0, 0, 0, 0)' && textColor != 'rgb(0, 0, 0)' && textColor != 'transparent') {
                    items.push('textColor');
                }
            }
            catch(e)
            {
                // DRM: I had to add these stupid try-catch blocks to solve an issue with t.css throwing
                // exceptions for no reason.
            }
            
            // Image
            if (nodeName == 'img') {
                ZSSEditor.currentEditingImage = t;
                items.push('image:'+t.attr('src'));
                if (t.attr('alt') !== undefined) {
                    items.push('image-alt:'+t.attr('alt'));
                }
            }
        }
    }

	ZSSEditor.stylesCallback(items);
};

// MARK: - Advanced Node Manipulation

/**
 *  @brief      Extracts a node from a parent node, and from all nodes in between the two.
 */
ZSSEditor.extractNodeFromAncestorNode = function(descendant, ancestor) {
    
    while (ancestor.contains(descendant)) {
        
        this.extractNodeFromParent(descendant);
        break;
    }
};

/**
 *  @brief      Extract the specified node from its direct parent node.
 *  @details    If the node has siblings, before or after it, the parent node is split accordingly
 *              into two new clones of it.
 */
ZSSEditor.extractNodeFromParent = function(node) {

    var parentNode = node.parentNode;
    var grandParentNode = parentNode.parentNode;
    var clonedParentForPreviousSiblings = null;
    var clonedParentForNextSiblings = null;
    
    if (node.previousSibling != null) {
        var clonedParentForPreviousSiblings = parentNode.cloneNode();
        
        while (parentNode.firstChild != node) {
            clonedParentForPreviousSiblings.appendChild(parentNode.firstChild);
        }
    }
    
    if (node.nextSibling != null) {
        var clonedParentForNextSiblings = parentNode.cloneNode();
        
        while (node.nextSibling != null) {
            clonedParentForNextSiblings.appendChild(node.nextSibling);
        }
    }
    
    if (clonedParentForPreviousSiblings) {
        grandParentNode.insertBefore(clonedParentForPreviousSiblings, parentNode);
    }
    
    grandParentNode.insertBefore(node, parentNode);
    
    if (clonedParentForNextSiblings) {
        grandParentNode.insertBefore(clonedParentForNextSiblings, parentNode);
    }
    
    grandParentNode.removeChild(parentNode);
};

ZSSEditor.getChildNodesIntersectingRange = function(parentNode, range) {
    
    var nodes = new Array();
    
    if (parentNode) {
        var currentNode = parentNode.firstChild;
        var pushNodes = false;
        var exit = false;
        
        while (currentNode) {
            
            if (range.intersectsNode(currentNode)) {
                nodes.push(currentNode);
            }
            
            currentNode = currentNode.nextSibling;
        }
    }
    
    return nodes;
};

/**
 *  @brief      Given the specified range, find the ancestor element that  will be used to set the
 *              blockquote ON or OFF.
 *
 *  @param      range       The range we want to set the blockquote ON or OFF for.
 *
 *  @returns    If a parent BLOCKQUOTE element is found, it will be return.  Otherwise the closest
 *              parent non-paragraph element will be returned.
 */
ZSSEditor.getAncestorElementForSettingBlockquote = function(range) {
    
    var nodes = new Array();
    var parentElement = range.commonAncestorContainer;
    
    while (parentElement
           && (parentElement.nodeType != document.ELEMENT_NODE
               || parentElement.nodeName == NodeName.PARAGRAPH)) {
        parentElement = parentElement.parentNode;
    }
    
    var currentElement = parentElement;
    
    while (currentElement
           && currentElement.nodeName != NodeName.BLOCKQUOTE) {
        currentElement = currentElement.parentElement;
    }
    
    var result = currentElement ? currentElement : parentElement;
    
    return result;
};

/**
 *  @brief      Joins any adjacent blockquote siblings.
 *  @details    You probably want to call joinAdjacentSiblingsOrAncestorBlockquotes() instead of
 *              this.
 *
 *  @returns    true if a sibling was joined.  false otherwise.
 */
ZSSEditor.joinAdjacentSiblingsBlockquotes = function(node) {
    
    var shouldJoinToPreviousSibling = this.hasPreviousSiblingWithName(node, NodeName.BLOCKQUOTE);
    var shouldJoinToNextSibling = this.hasNextSiblingWithName(node, NodeName.BLOCKQUOTE);
    var joinedASibling = (shouldJoinToPreviousSibling || shouldJoinToNextSibling);
    
    var previousSibling = node.previousSibling;
    var nextSibling = node.nextSibling;
    
    if (shouldJoinToPreviousSibling) {
        
        previousSibling.appendChild(node);
        
        if (shouldJoinToNextSibling) {
            
            while (nextSibling.firstChild) {
                previousSibling.appendChild(nextSibling.firstChild);
            }
            
            nextSibling.parentNode.removeChild(nextSibling);
        }
    } else if (shouldJoinToNextSibling) {
        
        nextSibling.insertBefore(node, nextSibling.firstChild);
    }
    
    return joinedASibling;
};

/**
 *  @brief      Joins any adjacent blockquote siblings, or the blockquote siblings of any ancestor.
 *  @details    When turning blockquotes back on, this method makes sure that we attach new
 *              blockquotes to exiting ones.
 *
 *  @returns    true if a sibling or ancestor sibling was joined.  false otherwise.
 */
ZSSEditor.joinAdjacentSiblingsOrAncestorBlockquotes = function(node) {
    
    var currentNode = node;
    var rootNode = this.getFocusedField().wrappedDomNode();
    var joined = false;
    
    while (currentNode
           && currentNode != rootNode
           && !joined) {
    
        joined = this.joinAdjacentSiblingsBlockquotes(currentNode);
        currentNode = currentNode.parentNode;
    };
    
    return joined;
};

/**
 *  @brief      Surrounds a node's contents into another node
 *  @details    When creating new nodes that should force paragraphs inside of them, this method
 *              should be called.
 *
 *  @param      node            The node that will have its contents wrapped into a new node.
 *  @param      wrapperNodeName The nodeName of the node that will created to wrap the contents.
 *
 *  @returns    The newly created wrapper node.
 */
ZSSEditor.surroundNodeContentsWithNode = function(node, wrapperNodeName) {
    
    var range = document.createRange();
    var wrapperNode = document.createElement(wrapperNodeName);
    
    range.selectNodeContents(node);
    range.surroundContents(wrapperNode);
    
    return wrapperNode;
};

/**
 *  @brief      Surrounds a node's contents with a paragraph node.
 *  @details    When creating new nodes that should force paragraphs inside of them, this method
 *              should be called.
 *
 *  @returns    The paragraph node.
 */
ZSSEditor.surroundNodeContentsWithAParagraphNode = function(node) {
    
    return this.surroundNodeContentsWithNode(node, this.defaultParagraphSeparator);
};

// MARK: - Sibling nodes

ZSSEditor.hasNextSiblingWithName = function(node, siblingNodeName) {
    return node.nextSibling && node.nextSibling.nodeName == siblingNodeName;
};

ZSSEditor.hasPreviousSiblingWithName = function(node, siblingNodeName) {
    return node.previousSibling && node.previousSibling.nodeName == siblingNodeName;
};

// MARK: - Parent nodes & tags

ZSSEditor.closerParentNode = function() {
    
    var parentNode = null;
    var selection = window.getSelection();
    var range = selection.getRangeAt(0).cloneRange();
    
    var currentNode = range.commonAncestorContainer;
    
    while (currentNode) {
        if (currentNode.nodeType == document.ELEMENT_NODE) {
            parentNode = currentNode;
            
            break;
        }
        
        currentNode = currentNode.parentElement;
    }
    
    return parentNode;
};

ZSSEditor.closerParentNodeStartingAtNode = function(nodeName, startingNode) {
    
    nodeName = nodeName.toLowerCase();
    
    var parentNode = null;
    var currentNode = startingNode.parentElement;
    
    while (currentNode) {
        
        if (currentNode.nodeName == document.body.nodeName) {
            break;
        }
        
        if (currentNode.nodeName.toLowerCase() == nodeName
            && currentNode.nodeType == document.ELEMENT_NODE) {
            parentNode = currentNode;
            
            break;
        }
        
        currentNode = currentNode.parentElement;
    }
    
    return parentNode;
};

ZSSEditor.closerParentNodeWithName = function(nodeName) {
    
    var parentNode = null;
    var selection = window.getSelection();
    if (selection.rangeCount < 1){
        return null;
    }
    var range = selection.getRangeAt(0).cloneRange();
    var referenceNode = range.commonAncestorContainer;
    
    return this.closerParentNodeWithNameRelativeToNode(nodeName, referenceNode);
};

ZSSEditor.closerParentNodeWithNameRelativeToNode = function(nodeName, referenceNode) {
    
    nodeName = nodeName.toUpperCase();
    
    var parentNode = null;
    var currentNode = referenceNode;
    
    while (currentNode) {
        
        if (currentNode.nodeName == document.body.nodeName) {
            break;
        }
        
        if (currentNode.nodeName == nodeName
            && currentNode.nodeType == document.ELEMENT_NODE) {
            parentNode = currentNode;
            
            break;
        }
        
        currentNode = currentNode.parentElement;
    }
    
    return parentNode;
};

ZSSEditor.isCloserParentNodeABlockquote = function() {
  return this.closerParentNode().nodeName == NodeName.BLOCKQUOTE;
};

ZSSEditor.parentTags = function() {
    
    var parentTags = [];
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    
    var currentNode = range.commonAncestorContainer;
    while (currentNode) {
        
        if (currentNode.nodeName == document.body.nodeName) {
            break;
        }
        
        if (currentNode.nodeType == document.ELEMENT_NODE) {
            parentTags.push(currentNode);
        }
        
        currentNode = currentNode.parentElement;
    }
    
    return parentTags;
};

// MARK: - ZSSField Constructor

function ZSSField(wrappedObject,
                  callbacker) {
    
    this.wrappedObject = wrappedObject;
    this.callbacker = callbacker;
    
    // When this bool is true, we are going to restrict input and certain callbacks
    // so IME keyboards behave properly when composing.
    this.isComposing = false;
    
    this.multiline = false;
    this.bodyPlaceholderColor = '#000000';
    
    if (this.wrappedDomNode().hasAttribute('nostyle')) {
        this.hasNoStyle = true;
    }

    this.useVisualFormatting = (this.wrappedObject.data("wpUseVisualFormatting") === "true")
    
    this.bindListeners();
};

ZSSField.prototype.bindListeners = function() {
    
    var thisObj = this;
    
    this.wrappedObject.bind('tap', function(e) { thisObj.handleTapEvent(e); });
    this.wrappedObject.bind('focus', function(e) { thisObj.handleFocusEvent(e); });
    this.wrappedObject.bind('blur', function(e) { thisObj.handleBlurEvent(e); });
    this.wrappedObject.bind('keydown', function(e) { thisObj.handleKeyDownEvent(e); });
    this.wrappedObject.bind('input', function(e) { thisObj.handleInputEvent(e); });
    this.wrappedObject.bind('compositionstart', function(e) { thisObj.handleCompositionStartEvent(e); });
    this.wrappedObject.bind('compositionend', function(e) { thisObj.handleCompositionEndEvent(e); });
    this.bindMutationObserver();
};

ZSSField.prototype.bindMutationObserver = function () {
    var target = this.wrappedObject[0];
    // create an observer instance
    var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            var removedNode = ZSSEditor.searchForMediaNode(mutation.removedNodes)
            if ( removedNode != null) {                
                var mediaIdentifier = ZSSEditor.extractMediaIdentifier(removedNode);
                ZSSEditor.sendMediaRemovedCallback(mediaIdentifier);
            }
        });
    });
    
    // configuration of the observer:
    var config = { attributes: false, childList: true, characterData: false, subtree: true };
    
    // pass in the target node, as well as the observer options
    observer.observe(target, config);
}

// MARK: - Emptying the field when it should be, well... empty (HTML madness)

/**
 *  @brief      Sometimes HTML leaves some <br> tags or &nbsp; when the user deletes all
 *              text from a contentEditable field.  This code makes sure no such 'garbage' survives.
 *  @details    If the node contains child image nodes, then the content is left untouched.
 */
ZSSField.prototype.emptyFieldIfNoContents = function() {

    var nbsp = '\xa0';
    var text = this.wrappedObject.text().replace(nbsp, '');
    
    if (text.length == 0) {
        
        var hasChildImages = (this.wrappedObject.find('img').length > 0);
        var hasChildVideos = (this.wrappedObject.find('video').length > 0);
        var hasUnorderedList = (this.wrappedObject.find('ul').length > 0);
        var hasOrderedList = (this.wrappedObject.find('ol').length > 0);
        
        if (!hasChildImages && !hasUnorderedList && !hasOrderedList && !hasChildVideos) {
            this.wrappedObject.empty();
        }
    }
};

ZSSField.prototype.emptyFieldIfNoContentsAndRefreshPlaceholderColor = function() {
    this.emptyFieldIfNoContents();
    this.refreshPlaceholderColor();
};

// MARK: - Handle event listeners

ZSSField.prototype.handleBlurEvent = function(e) {
    ZSSEditor.focusedField = null;

    this.emptyFieldIfNoContentsAndRefreshPlaceholderColor();
    
    this.callback("callback-focus-out");
};

ZSSField.prototype.handleFocusEvent = function(e) {
    ZSSEditor.focusedField = this;
    
    // IMPORTANT: this is the only case where checking the current focus will not work.
    // We sidestep this issue by indicating that the field is about to gain focus.
    //
    this.refreshPlaceholderColorAboutToGainFocus(true);
    this.callback("callback-focus-in");
};

ZSSField.prototype.handleKeyDownEvent = function(e) {
    
    var wasBackspaceOrDeletePressed = (e.keyCode == 8 || e.keyCode == 46);
    
    // We don't want to alter the default behaviour for the backspace and delete key.
    //
    // Ref: https://github.com/wordpress-mobile/WordPress-Editor-iOS/issues/803
    //
    if (wasBackspaceOrDeletePressed) {
        return;
    }
    
    var wasEnterPressed = (e.keyCode == '13');
    
    if (this.isComposing) {
        e.stopPropagation();
    } else if (wasEnterPressed
               && !this.isMultiline()) {
        e.preventDefault();
    } else if (this.isMultiline()) {
        this.wrapCaretInParagraphIfNecessary();
    }
};

ZSSField.prototype.handleInputEvent = function(e) {
    
    // Skip this if we are composing on an IME keyboard
    if (this.isComposing ) { return; }
    
    // IMPORTANT: we want the placeholder to come up if there's no text, so we clear the field if
    // there's no real content in it.  It's important to do this here and not on keyDown or keyUp
    // as the field could become empty because of a cut or paste operation as well as a key press.
    // This event takes care of all cases.
    //
    this.emptyFieldIfNoContentsAndRefreshPlaceholderColor();
    
    var joinedArguments = ZSSEditor.getJoinedFocusedFieldIdAndCaretArguments();

    this.callback('callback-selection-changed', joinedArguments);
    this.callback("callback-input", joinedArguments);
};

ZSSField.prototype.handleCompositionStartEvent = function(e) {
    this.isComposing = true;
};

ZSSField.prototype.handleCompositionEndEvent = function(e) {
    this.isComposing = false;
};

ZSSField.prototype.handleTapEvent = function(e) {
    var targetNode = e.target;
    
    if (targetNode) {
        
        ZSSEditor.lastTappedNode = targetNode;
        
        if (targetNode.nodeName.toLowerCase() == 'a') {
            var arguments = ['url=' + encodeURIComponent(targetNode.href),
                             'title=' + encodeURIComponent(targetNode.innerHTML)];
            
            var joinedArguments = arguments.join(defaultCallbackSeparator);
            
            var thisObj = this;
            
            // WORKAROUND: force the event to become sort of "after-tap" through setTimeout()
            //
            setTimeout(function() { thisObj.callback('callback-link-tap', joinedArguments);}, 500);
        }

        if (targetNode.nodeName.toLowerCase() == 'img') {
            // If the image is uploading, or is a local image do not select it.
            if ( targetNode.dataset.wpid ) {
                this.sendImageTappedCallback( targetNode );
                return;
            }
            
            // If we're not currently editing just return. No need to apply styles
            // or acknowledge the tap
            if ( this.wrappedObject.attr('contenteditable') != "true" ) {
                return;
            }

            // Is the tapped image the image we're editing?
            if ( targetNode == ZSSEditor.currentEditingImage ) {
                ZSSEditor.removeImageSelectionFormatting( targetNode );
                this.sendImageTappedCallback( targetNode );
                return;
            }

            // If there is a selected image, deselect it. A different image was tapped.
            if ( ZSSEditor.currentEditingImage ) {
                ZSSEditor.removeImageSelectionFormatting( ZSSEditor.currentEditingImage );
            }

            // Format and flag the image as selected.
            ZSSEditor.currentEditingImage = targetNode;
            ZSSEditor.applyImageSelectionFormatting( targetNode );

            return;
        }

        if (targetNode.className.indexOf('edit-overlay') != -1 || targetNode.className.indexOf('edit-content') != -1) {
            ZSSEditor.removeImageSelectionFormatting( ZSSEditor.currentEditingImage );
            this.sendImageTappedCallback( ZSSEditor.currentEditingImage );
            return;
        }

        if ( ZSSEditor.currentEditingImage ) {
            ZSSEditor.removeImageSelectionFormatting( ZSSEditor.currentEditingImage );
            ZSSEditor.currentEditingImage = null;
        }
        
        if (targetNode.nodeName.toLowerCase() == 'video') {
//             If the video is uploading, or is a local image do not select it.
            if ( targetNode.dataset.wpid ) {
                this.sendVideoTappedCallback( targetNode );
                return;
            }
        }
    }
};

ZSSField.prototype.sendImageTappedCallback = function( imageNode ) {
    var meta = JSON.stringify( ZSSEditor.extractImageMeta( imageNode ) );
    var imageId = "";
    if ( imageNode.hasAttribute( 'data-wpid' ) ){
        imageId = imageNode.getAttribute( 'data-wpid' )
    }
    var arguments = ['id=' + encodeURIComponent( imageId ),
                     'url=' + encodeURIComponent( imageNode.src ),
                     'meta=' + encodeURIComponent( meta )];

    var joinedArguments = arguments.join( defaultCallbackSeparator );

    var thisObj = this;

    // WORKAROUND: force the event to become sort of "after-tap" through setTimeout()
    //
    setTimeout(function() { ZSSEditor.callback('callback-image-tap', joinedArguments);}, 500);
}

ZSSField.prototype.sendVideoTappedCallback = function( videoNode ) {
    var videoId = "";
    if ( videoNode.hasAttribute( 'data-wpid' ) ){
        videoId = videoNode.getAttribute( 'data-wpid' )
    }
    var arguments = ['id=' + encodeURIComponent( videoId ),
                     'url=' + encodeURIComponent( videoNode.src )];
    
    var joinedArguments = arguments.join( defaultCallbackSeparator );
    
    ZSSEditor.callback('callback-video-tap', joinedArguments);
}

/**
 *  @brief      Callbacks to native that the video entered full screen mode
 *
 */
ZSSField.prototype.sendVideoFullScreenStarted = function() {
    this.callback("callback-video-fullscreen-started", "empty");
};

/**
 *  @brief      Callbacks to native that the video entered full screen mode
 *
 */
ZSSField.prototype.sendVideoFullScreenEnded = function() {
    this.callback("callback-video-fullscreen-ended", "empty");
};

// MARK: - Callback Execution

ZSSField.prototype.callback = function(callbackScheme, callbackPath) {
    
    var finalPath = "id=" + this.getNodeId();
    
    if (callbackPath && callbackPath.length > 0) {
        finalPath = finalPath + defaultCallbackSeparator + callbackPath;
    }
    
    this.callbacker.callback(callbackScheme, finalPath);
};

// MARK: - Focus

ZSSField.prototype.isFocused = function() {

    return this.wrappedObject.is(':focus');
};

ZSSField.prototype.focus = function() {
    
    if (!this.isFocused()) {
        this.wrappedObject.focus();
    }
};

ZSSField.prototype.blur = function() {
    if (this.isFocused()) {
        this.wrappedObject.blur();
    }
};

// MARK: - Multiline support

ZSSField.prototype.isMultiline = function() {
    return this.multiline;
};

ZSSField.prototype.setMultiline = function(multiline) {
    this.multiline = multiline;
};

// MARK: - NodeId

ZSSField.prototype.getNodeId = function() {
    return this.wrappedObject.attr('id');
};

// MARK: - Editing

ZSSField.prototype.enableEditing = function () {
    
    this.wrappedObject.attr('contenteditable', true);
    
    if (!ZSSEditor.focusedField) {
        ZSSEditor.focusFirstEditableField();
    }
};

ZSSField.prototype.disableEditing = function () {
    // IMPORTANT: we're blurring the field before making it non-editable since that ensures
    // that the iOS keyboard is dismissed through an animation, as opposed to being immediately
    // removed from the screen.
    //
    this.blur();
    
    this.wrappedObject.attr('contenteditable', false);
};

// MARK: - Caret


/**
 *  @brief      Whenever this method is called, a check will be performed on the caret position
 *              to figure out if it needs to be wrapped in a paragraph node.
 *  @details    A parent paragraph node should be added if the current parent is either the field
 *              node itself, or a blockquote node.
 */
ZSSField.prototype.wrapCaretInParagraphIfNecessary = function()
{
    var closerParentNode = ZSSEditor.closerParentNode();
    var parentNodeShouldBeParagraph = (closerParentNode == this.wrappedDomNode()
                                       || closerParentNode.nodeName == NodeName.BLOCKQUOTE);
    
    if (parentNodeShouldBeParagraph) {
        var selection = window.getSelection();
        
        if (selection) {
            var range = selection.getRangeAt(0);
            
            if (range.startContainer == range.endContainer) {
                var paragraph = document.createElement("p");
                var textNode = document.createTextNode("&#x200b;");
                
                paragraph.appendChild(textNode);
                
                range.insertNode(paragraph);
                range.selectNode(textNode);
                
                selection.removeAllRanges();
                selection.addRange(range);
            }
        }
    }
};

// MARK: - i18n

ZSSField.prototype.isRightToLeftTextEnabled = function() {
    var textDir = this.wrappedObject.attr('dir');
    var isRTL = (textDir != "undefined" && textDir == 'rtl');
    return isRTL;
};

ZSSField.prototype.enableRightToLeftText = function(isRTL) {
    var textDirectionString = isRTL ? "rtl" : "ltr";
    this.wrappedObject.attr('dir', textDirectionString);
    this.wrappedObject.css('direction', textDirectionString);
};

// MARK: - HTML contents

ZSSField.prototype.isEmpty = function() {
    var html = this.getHTML();
    var isEmpty = (html.length == 0 || html == "<br>");
    
    return isEmpty;
};

ZSSField.prototype.getHTML = function() {
    var html = wp.saveText(this.wrappedObject.html());
    html = ZSSEditor.removeVisualFormatting( html );
    return html
};

ZSSField.prototype.strippedHTML = function() {
    return this.wrappedObject.text();
};

ZSSField.prototype.setPlainText = function(text) {
    ZSSEditor.currentEditingImage = null;
    this.wrappedObject.text(text);
    this.refreshPlaceholderColor();
};

ZSSField.prototype.setHTML = function(html) {
    ZSSEditor.currentEditingImage = null;
    
    if (this.isMultiline()) {
        var mutatedHTML = wp.loadText(html);
        mutatedHTML = ZSSEditor.applyVisualFormatting(mutatedHTML);
        this.wrappedObject.html(mutatedHTML);
    } else {
        this.wrappedObject.html(html);
    }
    
    var thisObj = this;
    //bind events to any video present on the html.
    $('video').on('webkitbeginfullscreen', function (event){ thisObj.sendVideoFullScreenStarted();});
    $('video').on('webkitendfullscreen', function (event){ thisObj.sendVideoFullScreenEnded();});
    this.refreshPlaceholderColor();
};

// MARK: - Placeholder

ZSSField.prototype.hasPlaceholderText = function() {
    return this.wrappedObject.attr('placeholderText') != null;
};

ZSSField.prototype.setPlaceholderText = function(placeholder) {
    
    this.wrappedObject.attr('placeholderText', placeholder);
};

ZSSField.prototype.setPlaceholderColor = function(color) {
    this.bodyPlaceholderColor = color;
    this.refreshPlaceholderColor();
};

ZSSField.prototype.refreshPlaceholderColor = function() {
     this.refreshPlaceholderColorForAttributes(this.hasPlaceholderText(),
                                               this.isFocused(),
                                               this.isEmpty());
};

ZSSField.prototype.refreshPlaceholderColorAboutToGainFocus = function(willGainFocus) {
    this.refreshPlaceholderColorForAttributes(this.hasPlaceholderText(),
                                              willGainFocus,
                                              this.isEmpty());
};

ZSSField.prototype.refreshPlaceholderColorForAttributes = function(hasPlaceholderText, isFocused, isEmpty) {
    
    var shouldColorText = hasPlaceholderText && isEmpty;
    
    if (shouldColorText) {
        if (isFocused) {
            this.wrappedObject.css('color', this.bodyPlaceholderColor);
        } else {
            this.wrappedObject.css('color', this.bodyPlaceholderColor);
        }
    } else {
        this.wrappedObject.css('color', '');
    }
    
};

// MARK: - Wrapped Object

ZSSField.prototype.wrappedDomNode = function() {
    return this.wrappedObject[0];
};
