import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3
import "controls" as Controls
import StableDiffusion 1.0
import Qt.labs.platform 1.1

ApplicationWindow {
    id: window

    width: 600
    height: 600
    maximumHeight: 600
    minimumHeight: 600
    maximumWidth: 600
    minimumWidth: 600
    visible: true
    title: qsTr("SDImageGenerator")
    font.pointSize: 12
    property double startTime: 0

    TextToImageBackend{
        id : stableDiffusionBackend
    }

    MessageDialog
    {
        id: msgDialog

        title: qsTr("SDImageGenerator Error ")
        text: stableDiffusionBackend.errorMessage
        visible: false
        buttons: MessageDialog.Ok
        // icon: StandardIcon.Critical
    }

    Connections{
        target: stableDiffusionBackend

        function onShowMessageBox() {
            console.log("Show dialogue");
            msgDialog.visible = true;
        }

        function onInitControls(options) {
            promptInput.text = options.prompt;
            scaleSlider.slider.value = options.scale;
            widthSlider.slider.value = options.imageWidth;
            heightSlider.slider.value = options.imageHeight;
            imageCountSlider.slider.value = options.numberOfImages;
            ddimStepsSlider.slider.value = options.ddimSteps;
            samplerComboBox.currentIndex = samplerComboBox.indexOfValue(options.sampler);
            saveFolder.text = options.saveDir
            if (options.seed === 0)
                seedInput.text = "";
            else
                seedInput.text = options.seed;
        }

        function onSetOutputDirectory(directory){
            saveFolder.text = directory
        }
        function onIsProcessingChanged() {
            if (!stableDiffusionBackend.isProcessing)
            {
                tabBar.currentIndex = 1;
            }

        }
    }
    function getElapsedTime()
    {
        let elapsedSeconds = (new Date().getTime()-startTime)/1000.0
        let elapsedTimeFomatted =""
        if (elapsedSeconds>3600)
            elapsedTimeFomatted = new Date(elapsedSeconds * 1000).toISOString().slice(11, 19);
        else
            elapsedTimeFomatted = new Date(elapsedSeconds * 1000).toISOString().slice(14, 19);

        return elapsedTimeFomatted.toString();
    }

    function updateOptions(){

        stableDiffusionBackend.options.prompt = promptInput.text
        stableDiffusionBackend.options.scale = scaleSlider.slider.value.toFixed(1)
        stableDiffusionBackend.options.imageWidth = parseInt(widthSlider.slider.value)
        stableDiffusionBackend.options.imageHeight = parseInt(heightSlider.slider.value)
        stableDiffusionBackend.options.numberOfImages = parseInt(imageCountSlider.slider.value)
        stableDiffusionBackend.options.ddimSteps = parseInt(ddimStepsSlider.slider.value)
        stableDiffusionBackend.options.sampler = samplerComboBox.currentText
        stableDiffusionBackend.options.saveDir = saveFolder.text
        if (seedInput.text)
            stableDiffusionBackend.options.seed = seedInput.text
        else
            stableDiffusionBackend.options.seed = 0
    }
    TabBar {
        id: tabBar
        width: parent.width

        TabButton {
            text: qsTr("Text to Image")
            icon.source: "images/moon-stars-fill.png"
            background: Rectangle {
                color: tabBar.currentIndex ==0 ? "#262625": "#2e2e2e"
            }

        }
        TabButton {
            text: qsTr("Images")
            icon.source: "images/images.png"
            background: Rectangle {
                color: tabBar.currentIndex ==1 ? "#262625": "#2e2e2e"
            }

        }
        TabButton {
            text: qsTr("Settings")
              icon.source: "images/gear.png"
            background: Rectangle {
                color: tabBar.currentIndex ==2 ? "#262625": "#2e2e2e"
            }

        }
        TabButton {
            text: qsTr("About")
              icon.source: "images/gear.png"
            background: Rectangle {
                color: tabBar.currentIndex ==3 ? "#262625": "#2e2e2e"
            }

        }
        onCurrentIndexChanged: {
            layout.currentIndex = tabBar.currentIndex
        }

    }
    StackLayout {
        id: layout
        anchors.fill: parent
        currentIndex: 0
        anchors.topMargin: tabBar.height
        Page{


            RowLayout{
                Item{
                    width:20
                }
                ColumnLayout{
                    Item{
                        height:180
                    }
                    Label{
                        text:qsTr("Prompt")

                    }

                    Item{
                        width: 550
                        height:100
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter


                        ScrollView {
                            id: view
                            anchors.fill: parent
                            clip:true
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded

                            Controls.AppTextArea{
                                id: promptInput
                                placeholderText: "A virus playing guitar"
                                font.pointSize: 12
                            }
                        }
                    }

                    RowLayout{

                        Button{
                            //Layout.fillHeight: true
                            Layout.alignment: Qt.AlignRight
                            text: "Dream"
                            icon.color: "transparent"
                            icon.source: "images/moon-stars-fill.png"
                            enabled: !stableDiffusionBackend.isProcessing

                            onClicked: {
                                updateOptions();
                                startTime = new Date().getTime();
                                stableDiffusionBackend.generateImage();
                            }
                        }
                        Item{


                            Layout.fillWidth: true

                        }
                        BusyIndicator {
                            id: busyIndicator
                            visible: running
                            Layout.rightMargin: 10
                            running: stableDiffusionBackend.isProcessing
                        }

                        Label {

                            id:  elapsedTimeLabel
                            Layout.alignment: Qt.AlignRight
                            text: "00:00"
                            color: "gray"
                            font.pointSize: 10
                            Layout.bottomMargin: 5
                        }
                        /* Button{
                        id : buttonOpen
                        Layout.alignment: Qt.AlignLeft
                        text : "Open Output Folder"
                        icon.source: "images/folder2-open.png"
                        enabled: !stableDiffusionBackend.isProcessing
                        onClicked: stableDiffusionBackend.openOutputFolder();
                    }*/
                    }


                }
            }//
            Timer {
                id: elasedTimer
                interval: 1000;
                running: stableDiffusionBackend.isProcessing;
                repeat: true
                onTriggered: {
                    //elapsedTimeLabel.
                    elapsedTimeLabel.text = getElapsedTime();
                }
            }
            footer:RowLayout{
                Item{
                    width : 5
                }
                Label {
                    text: stableDiffusionBackend.diffusionStatusMessage
                    font.pointSize: 10
                    Layout.bottomMargin: 10
                }
            }
        }

        Page{
            id: paneImages
            RowLayout{
                Controls.ImageViewer{
                    id: imageViewer
                    Layout.leftMargin: 70
                    currentImagePath: "../../images/placeholder.png"
                    folderpath: stableDiffusionBackend.samplesUrl
                }
                Button {
                    width:32
                    Layout.alignment:  Qt.AlignBottom
                    icon.source: "images/folder2-open.png"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Open output folder")
                    onClicked: stableDiffusionBackend.openOutputFolder();
                }
            }
        }

        ScrollView
        {
            //width: window.width
            //height: window.height
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout
            {
                width: 550
                Item {
                    id: spacer
                    width: 25
                }

                ColumnLayout{
                    id : column
                    spacing: 10


                    Controls.AppLabel{
                        Layout.topMargin: 30
                        labelText:qsTr("Sampler")
                        labelInfo: qsTr("The diffusion sampling method. Default is PLMS.")

                    }
                    Item{
                        height:45
                        ComboBox{
                            id: samplerComboBox
                            height:45
                            Layout.fillHeight: true

                            model: ["plms", "ddim"]
                        }
                    }

                    Controls.AppSlider{
                        id : scaleSlider

                        header.text: qsTr("Guidance scale")
                        description.text: qsTr("Higher values keep your image closer to your prompt.")
                        slider {

                            from:1
                            to:10
                            value: 7.5
                        }
                        Layout.fillWidth:true
                        displayFloat: true
                    }

                    Controls.AppSlider{
                        id: widthSlider

                        header.text: qsTr("Width")
                        description.text: qsTr("The width of the generated image.")
                        slider.from: 256
                        slider.to: 2000
                        slider.value: 512
                        Layout.fillWidth:true
                    }

                    Controls.AppSlider{
                        id: heightSlider

                        header.text: qsTr("Height")
                        description.text: qsTr("The height of the generated image.")
                        slider.from:256
                        slider.to:2000
                        slider.value: 512
                        Layout.fillWidth:true
                    }

                    Controls.AppSlider{
                        id: imageCountSlider

                        header.text: qsTr("Number of Images")
                        description.text: qsTr("Number of images to generate.")
                        slider.from: 1
                        slider.to: 20
                        slider.value: 1
                        Layout.fillWidth:true
                    }

                    Controls.AppSlider{
                        id: ddimStepsSlider

                        header.text: qsTr("DDIM Steps")
                        description.text: qsTr("Number of DDIM sampling steps")
                        slider.from:1
                        slider.to:150
                        slider.value: 50
                        Layout.fillWidth:true
                    }

                    Controls.AppLabel{
                        labelText:qsTr("Seed")
                        labelInfo: qsTr("Set a number to reproducible sampling.")
                    }

                    Controls.RichTextEdit{
                        id : seedInput

                        Layout.fillWidth:true
                        placeholderText: "Random seed"
                        validator: IntValidator {bottom: 1; top: 9999999}
                    }

                    Controls.AppLabel{
                        labelText:qsTr("Save path")
                        labelInfo: qsTr("Root folder to save generated images")

                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Controls.RichTextEdit{
                            id: saveFolder
                            Layout.fillWidth: true

                        }
                        FolderDialog {
                            id: folderDialog
                            folder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
                            onAccepted: {
                                stableDiffusionBackend.setOutputFolder(folder)
                            }
                        }
                        ToolButton{
                            icon.source: "images/folder2-open.png"
                            onClicked: folderDialog.open()

                        }
                    }

                    Button{
                        text : "Reset All"
                        onClicked: stableDiffusionBackend.resetSettings()
                    }
                }
            }
        }
       Page {
           Text{

               text : "Stable diffusion UI \nCopyright 2022 Rupesh Sreeraman"
               color : "white"
               font.pointSize: 12
               anchors.centerIn: parent
           }

        }
    }

    onClosing: {
        updateOptions();
        stableDiffusionBackend.saveSettings();
    }

}
