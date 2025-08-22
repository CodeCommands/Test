# Salesforce Automated User Provisioning Framework

## Configuration Guide for Application Teams

### Overview

The Automated User Provisioning framework enables application teams to streamline user onboarding through an automated workflow. Users submit access requests via a public website, which triggers an approval process and automatic user creation upon approval.

**Key Components:**

- Public access request form and status check page
- User Access Request (UAR) object for tracking requests
- Approval workflow with designated approvers
- Automated user creation based on configurable settings
- Role-based access controls and sharing rules

-----

## Prerequisites

Before configuring your application, ensure you have:

- **System Administrator** or equivalent permissions
- Access to **Setup** in your Salesforce org
- Understanding of your application’s user roles and permissions
- List of designated approvers for your application

-----

## Configuration Steps

### Step 1: Configure Picklist Values

#### 1.1 Add Your Application to Salesforce Application Picklist

1. Navigate to **Setup** → **Object Manager** → **User Access Request**
1. Click **Fields & Relationships**
1. Locate and click on **Salesforce Application** field
1. Scroll down to **Values** section and click **New**
1. Enter your application name (e.g., “MyApp”, “FinanceSystem”)
1. Click **Save**

#### 1.2 Add Application Roles

1. From the same User Access Request object, click on **Application Role** field
1. In the **Values** section, click **New**
1. Add each user role for your application (e.g., “MyApp_User”, “MyApp_Admin”)
1. Repeat for all roles your application requires
1. Click **Save**

#### 1.3 Configure Field Dependencies

1. Navigate to **Setup** → **Object Manager** → **User Access Request** → **Fields & Relationships**
1. Click **Field Dependencies**
1. Click **New** to create a new dependency
1. Set **Controlling Field**: Salesforce Application
1. Set **Dependent Field**: Application Role
1. In the dependency matrix:
- Select your application name in the controlling field column
- Check the appropriate application roles that should be available
1. Click **Save**

-----

### Step 2: Create Security Groups and Queues

#### 2.1 Create Application User Access Approver Public Group

1. Navigate to **Setup** → **Users** → **Public Groups**
1. Click **New**
1. **Label**: `[YourApp] User Access Approvers` (e.g., “MyApp User Access Approvers”)
1. **Name**: Auto-populated based on label
1. **Type**: Regular
1. In the **Search** section, find and add your approver users
1. Click **Save**

#### 2.2 Create Application User Access Approver Queue

1. Navigate to **Setup** → **Users** → **Queues**
1. Click **New**
1. **Label**: `[YourApp] User Access Approver Queue`
1. **Name**: Note this developer name for later use
1. **Supported Objects**: Select “User Access Request”
1. In **Queue Members**:
- **Search**: Public Groups
- **Available Members**: Select the public group created in Step 2.1
- Move it to **Selected Members**
1. Click **Save**

-----

### Step 3: Assign Permission Sets

#### 3.1 Assign Permission Set to Approvers

1. Navigate to **Setup** → **Users** → **Permission Sets**
1. Find and click **User Access Request Approvers**
1. Click **Manage Assignments**
1. Click **Add Assignments**
1. Select all users who are approvers for your application
1. Click **Assign** → **Done**

-----

### Step 4: Configure Sharing Rules

#### 4.1 Create User Access Request Sharing Rule

1. Navigate to **Setup** → **Security** → **Sharing Settings**
1. Scroll down to **User Access Request Sharing Rules**
1. Click **New** → **Criteria-based**
1. Fill in the following:
- **Label**: `Share with [YourApp] Approvers`
- **Rule Name**: Auto-populated
- **Description**: `Share with [YourApp] Approver`
1. **Step 1: Select your rule type**
- **Criteria**:
  - **Field**: Salesforce Application
  - **Operator**: equals
  - **Value**: [Your application name from Step 1.1]
1. **Additional Options** (if needed):
- ☑️ Include records owned by users who can’t have an assigned role (if applicable)
1. **Share with**:
- **Group**: [YourApp] User Access Approvers (public group from Step 2.1)
- **Access Level**: Read/Write
1. Click **Save**

-----

### Step 5: Create Custom Metadata Records

#### 5.1 Add User Creation Settings Metadata

For each user role/persona in your application, create a separate metadata record:

1. Navigate to **Setup** → **Custom Metadata Types** → **User Creation Settings** → **Manage Records**
1. Click **New**
1. Configure the following fields:

**Required Fields:**

- **Label**: Must start with your Salesforce Application picklist value (e.g., “MyApp User Settings”, “MyApp Admin Settings”)
- **User Creation Settings Name**: Auto-populated

**Configuration Fields:**

- **Profile**: Label of the Salesforce profile to assign (e.g., “Standard User”, “System Administrator”)
- **Permission Set Groups**: Comma-separated list of permission set group labels
  - Example: `MyApp_Users,Basic_Access`
  - ⚠️ **Important**: No spaces before or after commas
- **Public Groups**: Comma-separated list of public group labels
  - Example: `MyApp_Users,Department_Finance`
  - ⚠️ **Important**: No spaces before or after commas
- **Role**: Salesforce role to assign (if applicable)
- **User Fields**: Pre-populate user record fields using format `FieldName1:value,FieldName2:value`
  - Example: `Department:IT,Title:Application User`
- **Approver Queue**: Developer name of the queue created in Step 2.2

1. Click **Save**
1. Repeat for each user role/persona in your application

-----

## Configuration Examples

### Example 1: Finance Application Setup

**Application**: “FinanceApp”

**Roles**:

- FinanceApp_Viewer
- FinanceApp_Editor
- FinanceApp_Admin

**Metadata Records**:

**Record 1 - Viewer**:

- Label: `FinanceApp Viewer Settings`
- Profile: `Standard User`
- Permission Set Groups: `FinanceApp_Base,Company_Standard`
- Public Groups: `FinanceApp_Users,Finance_Department`
- Approver Queue: `FinanceApp_User_Access_Approver_Queue`

**Record 2 - Admin**:

- Label: `FinanceApp Admin Settings`
- Profile: `Standard User`
- Permission Set Groups: `FinanceApp_Base,FinanceApp_Admin,Company_Standard`
- Public Groups: `FinanceApp_Admins,Finance_Department`
- User Fields: `Department:Finance,Title:Finance Administrator`
- Approver Queue: `FinanceApp_User_Access_Approver_Queue`

-----

## Validation Checklist

Before going live, verify the following:

### ✅ Picklist Configuration

- [ ] Application added to Salesforce Application picklist
- [ ] All user roles added to Application Role picklist
- [ ] Field dependency configured correctly

### ✅ Security Setup

- [ ] Public group created with correct approvers
- [ ] Queue created with public group as member
- [ ] Permission set assigned to all approvers

### ✅ Sharing Rules

- [ ] Sharing rule created with correct criteria
- [ ] Rule targets the correct public group
- [ ] Access level set to Read/Write

### ✅ Metadata Configuration

- [ ] Metadata record created for each user role
- [ ] Labels start with application name
- [ ] All required fields populated correctly
- [ ] No spaces in comma-separated values

-----

## Testing Your Configuration

### Test Scenario

1. Create a test User Access Request record
1. Set Salesforce Application to your application
1. Verify the sharing rule grants access to your approvers
1. Test the approval process workflow
1. Confirm user creation with correct permissions

### Common Issues and Solutions

**Issue**: Approvers can’t see requests

- **Solution**: Verify sharing rule criteria matches exactly with picklist value

**Issue**: Field dependency not working

- **Solution**: Check that controlling and dependent fields are configured correctly

**Issue**: User creation fails

- **Solution**: Verify all referenced profiles, permission sets, and groups exist and are spelled correctly

-----

## Support and Maintenance

### Regular Maintenance Tasks

- Review and update approver lists quarterly
- Audit user creation settings annually
- Monitor approval queue performance

### Getting Help

For technical issues or questions about this framework:

1. Check the validation checklist above
1. Review error logs in Setup → Debug Logs
1. Contact your Salesforce Administrator team
1. Reference Salesforce documentation for object-specific configurations

-----

## Appendix

### Naming Conventions

- **Public Groups**: `[AppName] User Access Approvers`
- **Queues**: `[AppName] User Access Approver Queue`
- **Sharing Rules**: `Share with [AppName] Approvers`
- **Metadata Labels**: `[AppName] [Role] Settings`

### Best Practices

- Use consistent naming conventions across all applications
- Document any custom field mappings in User Fields
- Keep approver groups lean but ensure coverage
- Test configuration changes in a sandbox environment first
- Maintain documentation of your specific configuration choices
