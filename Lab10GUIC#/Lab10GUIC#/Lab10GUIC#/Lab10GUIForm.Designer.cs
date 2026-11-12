namespace Lab10GUIC_
{
    partial class Lab10GUIForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
            backgroundWorker1 = new System.ComponentModel.BackgroundWorker();
            ConnectionGroupBox = new GroupBox();
            PortsComboBox = new ComboBox();
            StatusLabel = new Label();
            CommandsGroupBox = new GroupBox();
            PacketPreviewTextBox = new TextBox();
            SendButton = new Button();
            RawFrameTextBox = new TextBox();
            OutputTextBox = new TextBox();
            DataModeComboBox = new ComboBox();
            ReadCountTextBox = new TextBox();
            AddressTextBox = new TextBox();
            OperationComboBox = new ComboBox();
            SavedGroupBox = new GroupBox();
            SendSavedButton = new Button();
            DeleteCommandButton = new Button();
            LoadCommandButton = new Button();
            SaveCommandButton = new Button();
            SavedCommandsComboBox = new ComboBox();
            SavedNameTextBox = new TextBox();
            ScannerGroupBox = new GroupBox();
            FoundAddressesListBox = new ListBox();
            ScanResultsListBox = new ListBox();
            ScanStatusLabel = new Label();
            ScanButton = new Button();
            HistoryGroupBox = new GroupBox();
            ExitButton = new Button();
            ComListBox = new ListBox();
            StatusTimer = new System.Windows.Forms.Timer(components);
            ConnectionGroupBox.SuspendLayout();
            CommandsGroupBox.SuspendLayout();
            SavedGroupBox.SuspendLayout();
            ScannerGroupBox.SuspendLayout();
            HistoryGroupBox.SuspendLayout();
            SuspendLayout();
            // 
            // ConnectionGroupBox
            // 
            ConnectionGroupBox.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            ConnectionGroupBox.Controls.Add(PortsComboBox);
            ConnectionGroupBox.Controls.Add(StatusLabel);
            ConnectionGroupBox.Location = new Point(15, 5);
            ConnectionGroupBox.Margin = new Padding(4);
            ConnectionGroupBox.Name = "ConnectionGroupBox";
            ConnectionGroupBox.Padding = new Padding(4);
            ConnectionGroupBox.Size = new Size(212, 131);
            ConnectionGroupBox.TabIndex = 0;
            ConnectionGroupBox.TabStop = false;
            ConnectionGroupBox.Text = "Connection Status";
            ConnectionGroupBox.Enter += ConnectionGroupBox_Enter;
            // 
            // PortsComboBox
            // 
            PortsComboBox.FormattingEnabled = true;
            PortsComboBox.Location = new Point(8, 84);
            PortsComboBox.Margin = new Padding(4);
            PortsComboBox.Name = "PortsComboBox";
            PortsComboBox.Size = new Size(188, 33);
            PortsComboBox.TabIndex = 1;
            // 
            // StatusLabel
            // 
            StatusLabel.AutoSize = true;
            StatusLabel.Location = new Point(8, 40);
            StatusLabel.Margin = new Padding(4, 0, 4, 0);
            StatusLabel.Name = "StatusLabel";
            StatusLabel.Size = new Size(119, 25);
            StatusLabel.TabIndex = 0;
            StatusLabel.Text = "Disconnected";
            // 
            // CommandsGroupBox
            // 
            CommandsGroupBox.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            CommandsGroupBox.Controls.Add(PacketPreviewTextBox);
            CommandsGroupBox.Controls.Add(SendButton);
            CommandsGroupBox.Controls.Add(RawFrameTextBox);
            CommandsGroupBox.Controls.Add(OutputTextBox);
            CommandsGroupBox.Controls.Add(DataModeComboBox);
            CommandsGroupBox.Controls.Add(ReadCountTextBox);
            CommandsGroupBox.Controls.Add(AddressTextBox);
            CommandsGroupBox.Controls.Add(OperationComboBox);
            CommandsGroupBox.Location = new Point(249, 5);
            CommandsGroupBox.Margin = new Padding(4);
            CommandsGroupBox.Name = "CommandsGroupBox";
            CommandsGroupBox.Padding = new Padding(4);
            CommandsGroupBox.Size = new Size(652, 382);
            CommandsGroupBox.TabIndex = 1;
            CommandsGroupBox.TabStop = false;
            CommandsGroupBox.Text = "UART / I2C Commands";
            // 
            // PacketPreviewTextBox
            // 
            PacketPreviewTextBox.Location = new Point(19, 292);
            PacketPreviewTextBox.Margin = new Padding(4);
            PacketPreviewTextBox.Name = "PacketPreviewTextBox";
            PacketPreviewTextBox.Size = new Size(625, 31);
            PacketPreviewTextBox.TabIndex = 7;
            // 
            // SendButton
            // 
            SendButton.Location = new Point(18, 331);
            SendButton.Margin = new Padding(4);
            SendButton.Name = "SendButton";
            SendButton.Size = new Size(626, 42);
            SendButton.TabIndex = 6;
            SendButton.Text = "Send Command";
            SendButton.UseVisualStyleBackColor = true;
            SendButton.Click += SendButton_Click;
            // 
            // RawFrameTextBox
            // 
            RawFrameTextBox.Location = new Point(19, 251);
            RawFrameTextBox.Margin = new Padding(4);
            RawFrameTextBox.Name = "RawFrameTextBox";
            RawFrameTextBox.Size = new Size(625, 31);
            RawFrameTextBox.TabIndex = 5;
            // 
            // OutputTextBox
            // 
            OutputTextBox.Location = new Point(19, 210);
            OutputTextBox.Margin = new Padding(4);
            OutputTextBox.Name = "OutputTextBox";
            OutputTextBox.Size = new Size(625, 31);
            OutputTextBox.TabIndex = 4;
            OutputTextBox.Text = "01 41";
            // 
            // DataModeComboBox
            // 
            DataModeComboBox.FormattingEnabled = true;
            DataModeComboBox.Location = new Point(19, 168);
            DataModeComboBox.Margin = new Padding(4);
            DataModeComboBox.Name = "DataModeComboBox";
            DataModeComboBox.Size = new Size(625, 33);
            DataModeComboBox.TabIndex = 3;
            // 
            // ReadCountTextBox
            // 
            ReadCountTextBox.Location = new Point(19, 126);
            ReadCountTextBox.Margin = new Padding(4);
            ReadCountTextBox.Name = "ReadCountTextBox";
            ReadCountTextBox.Size = new Size(625, 31);
            ReadCountTextBox.TabIndex = 2;
            ReadCountTextBox.Text = "1";
            // 
            // AddressTextBox
            // 
            AddressTextBox.Location = new Point(19, 85);
            AddressTextBox.Margin = new Padding(4);
            AddressTextBox.Name = "AddressTextBox";
            AddressTextBox.Size = new Size(625, 31);
            AddressTextBox.TabIndex = 1;
            AddressTextBox.Text = "20";
            // 
            // OperationComboBox
            // 
            OperationComboBox.FormattingEnabled = true;
            OperationComboBox.Location = new Point(19, 40);
            OperationComboBox.Margin = new Padding(4);
            OperationComboBox.Name = "OperationComboBox";
            OperationComboBox.Size = new Size(625, 33);
            OperationComboBox.TabIndex = 0;
            // 
            // SavedGroupBox
            // 
            SavedGroupBox.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            SavedGroupBox.Controls.Add(SendSavedButton);
            SavedGroupBox.Controls.Add(DeleteCommandButton);
            SavedGroupBox.Controls.Add(LoadCommandButton);
            SavedGroupBox.Controls.Add(SaveCommandButton);
            SavedGroupBox.Controls.Add(SavedCommandsComboBox);
            SavedGroupBox.Controls.Add(SavedNameTextBox);
            SavedGroupBox.Location = new Point(15, 144);
            SavedGroupBox.Margin = new Padding(4);
            SavedGroupBox.Name = "SavedGroupBox";
            SavedGroupBox.Padding = new Padding(4);
            SavedGroupBox.Size = new Size(212, 387);
            SavedGroupBox.TabIndex = 2;
            SavedGroupBox.TabStop = false;
            SavedGroupBox.Text = "Saved Commands";
            // 
            // SendSavedButton
            // 
            SendSavedButton.Location = new Point(14, 330);
            SendSavedButton.Margin = new Padding(4);
            SendSavedButton.Name = "SendSavedButton";
            SendSavedButton.Size = new Size(189, 50);
            SendSavedButton.TabIndex = 6;
            SendSavedButton.Text = "Retransmit";
            SendSavedButton.UseVisualStyleBackColor = true;
            SendSavedButton.Click += SendSavedButton_Click;
            // 
            // DeleteCommandButton
            // 
            DeleteCommandButton.Location = new Point(14, 272);
            DeleteCommandButton.Margin = new Padding(4);
            DeleteCommandButton.Name = "DeleteCommandButton";
            DeleteCommandButton.Size = new Size(189, 50);
            DeleteCommandButton.TabIndex = 5;
            DeleteCommandButton.Text = "Delete";
            DeleteCommandButton.UseVisualStyleBackColor = true;
            DeleteCommandButton.Click += DeleteCommandButton_Click;
            // 
            // LoadCommandButton
            // 
            LoadCommandButton.Location = new Point(14, 214);
            LoadCommandButton.Margin = new Padding(4);
            LoadCommandButton.Name = "LoadCommandButton";
            LoadCommandButton.Size = new Size(189, 51);
            LoadCommandButton.TabIndex = 4;
            LoadCommandButton.Text = "Load/Edit";
            LoadCommandButton.UseVisualStyleBackColor = true;
            LoadCommandButton.Click += LoadCommandButton_Click;
            // 
            // SaveCommandButton
            // 
            SaveCommandButton.Location = new Point(14, 161);
            SaveCommandButton.Margin = new Padding(4);
            SaveCommandButton.Name = "SaveCommandButton";
            SaveCommandButton.Size = new Size(189, 48);
            SaveCommandButton.TabIndex = 3;
            SaveCommandButton.Text = "Save/Upload";
            SaveCommandButton.UseVisualStyleBackColor = true;
            SaveCommandButton.Click += SaveCommandButton_Click;
            // 
            // SavedCommandsComboBox
            // 
            SavedCommandsComboBox.FormattingEnabled = true;
            SavedCommandsComboBox.Location = new Point(8, 79);
            SavedCommandsComboBox.Margin = new Padding(4);
            SavedCommandsComboBox.Name = "SavedCommandsComboBox";
            SavedCommandsComboBox.Size = new Size(188, 33);
            SavedCommandsComboBox.TabIndex = 1;
            // 
            // SavedNameTextBox
            // 
            SavedNameTextBox.Location = new Point(8, 38);
            SavedNameTextBox.Margin = new Padding(4);
            SavedNameTextBox.Name = "SavedNameTextBox";
            SavedNameTextBox.Size = new Size(188, 31);
            SavedNameTextBox.TabIndex = 0;
            // 
            // ScannerGroupBox
            // 
            ScannerGroupBox.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            ScannerGroupBox.Controls.Add(FoundAddressesListBox);
            ScannerGroupBox.Controls.Add(ScanResultsListBox);
            ScannerGroupBox.Controls.Add(ScanStatusLabel);
            ScannerGroupBox.Controls.Add(ScanButton);
            ScannerGroupBox.Location = new Point(909, 5);
            ScannerGroupBox.Margin = new Padding(4);
            ScannerGroupBox.Name = "ScannerGroupBox";
            ScannerGroupBox.Padding = new Padding(4);
            ScannerGroupBox.Size = new Size(371, 382);
            ScannerGroupBox.TabIndex = 3;
            ScannerGroupBox.TabStop = false;
            ScannerGroupBox.Text = "I2C Address Scanner";
            // 
            // FoundAddressesListBox
            // 
            FoundAddressesListBox.FormattingEnabled = true;
            FoundAddressesListBox.Location = new Point(8, 316);
            FoundAddressesListBox.Margin = new Padding(4);
            FoundAddressesListBox.Name = "FoundAddressesListBox";
            FoundAddressesListBox.Size = new Size(355, 54);
            FoundAddressesListBox.TabIndex = 3;
            // 
            // ScanResultsListBox
            // 
            ScanResultsListBox.FormattingEnabled = true;
            ScanResultsListBox.Location = new Point(8, 129);
            ScanResultsListBox.Margin = new Padding(4);
            ScanResultsListBox.Name = "ScanResultsListBox";
            ScanResultsListBox.Size = new Size(355, 179);
            ScanResultsListBox.TabIndex = 2;
            // 
            // ScanStatusLabel
            // 
            ScanStatusLabel.AutoSize = true;
            ScanStatusLabel.Location = new Point(8, 94);
            ScanStatusLabel.Margin = new Padding(4, 0, 4, 0);
            ScanStatusLabel.Name = "ScanStatusLabel";
            ScanStatusLabel.Size = new Size(114, 25);
            ScanStatusLabel.TabIndex = 1;
            ScanStatusLabel.Text = "Not Scanned";
            // 
            // ScanButton
            // 
            ScanButton.Location = new Point(8, 24);
            ScanButton.Margin = new Padding(4);
            ScanButton.Name = "ScanButton";
            ScanButton.Size = new Size(356, 58);
            ScanButton.TabIndex = 0;
            ScanButton.Text = "Scan I2C Bus";
            ScanButton.UseVisualStyleBackColor = true;
            ScanButton.Click += ScanButton_Click;
            // 
            // HistoryGroupBox
            // 
            HistoryGroupBox.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            HistoryGroupBox.Controls.Add(ComListBox);
            HistoryGroupBox.Location = new Point(249, 395);
            HistoryGroupBox.Margin = new Padding(4);
            HistoryGroupBox.Name = "HistoryGroupBox";
            HistoryGroupBox.Padding = new Padding(4);
            HistoryGroupBox.Size = new Size(1031, 321);
            HistoryGroupBox.TabIndex = 4;
            HistoryGroupBox.TabStop = false;
            HistoryGroupBox.Text = "Communication History";
            // 
            // ExitButton
            // 
            ExitButton.Location = new Point(29, 539);
            ExitButton.Margin = new Padding(4);
            ExitButton.Name = "ExitButton";
            ExitButton.Size = new Size(168, 104);
            ExitButton.TabIndex = 1;
            ExitButton.Text = "Exit";
            ExitButton.UseVisualStyleBackColor = true;
            ExitButton.Click += ExitButton_Click;
            // 
            // ComListBox
            // 
            ComListBox.FormattingEnabled = true;
            ComListBox.Location = new Point(8, 32);
            ComListBox.Margin = new Padding(4);
            ComListBox.Name = "ComListBox";
            ComListBox.Size = new Size(1015, 279);
            ComListBox.TabIndex = 0;
            // 
            // StatusTimer
            // 
            StatusTimer.Interval = 20;
            StatusTimer.Tick += StatusTimer_Tick;
            // 
            // Lab10GUIForm
            // 
            AutoScaleDimensions = new SizeF(10F, 25F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1314, 731);
            Controls.Add(ExitButton);
            Controls.Add(HistoryGroupBox);
            Controls.Add(ScannerGroupBox);
            Controls.Add(SavedGroupBox);
            Controls.Add(CommandsGroupBox);
            Controls.Add(ConnectionGroupBox);
            Margin = new Padding(4);
            Name = "Lab10GUIForm";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Lab 10 GUI Master/Slave Controller";
            ConnectionGroupBox.ResumeLayout(false);
            ConnectionGroupBox.PerformLayout();
            CommandsGroupBox.ResumeLayout(false);
            CommandsGroupBox.PerformLayout();
            SavedGroupBox.ResumeLayout(false);
            SavedGroupBox.PerformLayout();
            ScannerGroupBox.ResumeLayout(false);
            ScannerGroupBox.PerformLayout();
            HistoryGroupBox.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion

        private System.ComponentModel.BackgroundWorker backgroundWorker1;
        private GroupBox ConnectionGroupBox;
        private ComboBox PortsComboBox;
        private Label StatusLabel;
        private GroupBox CommandsGroupBox;
        private TextBox AddressTextBox;
        private ComboBox OperationComboBox;
        private ComboBox DataModeComboBox;
        private TextBox ReadCountTextBox;
        private TextBox RawFrameTextBox;
        private TextBox OutputTextBox;
        private Button SendButton;
        private GroupBox SavedGroupBox;
        private ComboBox SavedCommandsComboBox;
        private TextBox SavedNameTextBox;
        private Button SendSavedButton;
        private Button DeleteCommandButton;
        private Button LoadCommandButton;
        private Button SaveCommandButton;
        private GroupBox ScannerGroupBox;
        private ListBox ScanResultsListBox;
        private Label ScanStatusLabel;
        private Button ScanButton;
        private ListBox FoundAddressesListBox;
        private GroupBox HistoryGroupBox;
        private Button ExitButton;
        private ListBox ComListBox;
        private System.Windows.Forms.Timer StatusTimer;
        private TextBox PacketPreviewTextBox;
    }
}