import React, {PropTypes} from 'react'
import {connect} from 'react-redux'

import {IconButton} from 'material-ui'
import FileUpload from 'material-ui/lib/svg-icons/file/file-upload.js'

//import {STATUS} from '../actions/upload'
const STATUS = {}

let UploadButton = ({upload, onClick}) => {
	let icon = (() => {
		switch (upload.status) {
			case STATUS.UPLOADING:
				return <FileUpload color={"white"} className={"wiggle"}/>
			case STATUS.NOTUPLOADING:
				return <FileUpload color={"white"} className={"greyed-out"}/>
		}
	})()
  return(
    <IconButton
      onClick={() => {
				onClick()
			}}>
      {icon}
    </IconButton>
  )
}

const mapStateToProps = (state) => {
	return {
		upload: {}
	}
}

const mapDispatchToProps = (dispatch) => {
	return {
		onClick: ()=>{}
	}
}

UploadButton = connect(
	mapStateToProps,
	mapDispatchToProps
)(UploadButton)

export default UploadButton
