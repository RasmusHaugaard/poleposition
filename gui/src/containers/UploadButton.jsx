import React, {PropTypes, Component} from 'react'
import {connect} from 'react-redux'

import {IconButton, CircularProgress} from 'material-ui'
import FileUpload from 'material-ui/lib/svg-icons/file/file-upload.js'

import {STATUS, blProgram} from '../actions/bl'

class UploadButton extends Component{
	constructor(props){
		super(props)
	}
	render(){
		let {status, progress, onClick} = this.props
		let icon = (
			status === STATUS.PROGRAMMING ?
				<FileUpload color={"white"} className={"wiggle"}/>
				:
				<FileUpload color={"white"} className={"greyed-out"}/>
		)
		return(
			<IconButton
				onClick={() => {
					if(status === STATUS.NOT_PROGRAMMING) onClick()
				}}>
				{icon}
			</IconButton>
		)
	}
}

const mapStateToProps = (state) => {
	return {
		status: state.bl.status,
		progress: state.bl.progress
	}
}

const mapDispatchToProps = (dispatch) => {
	return {
		onClick: (status) => {
			dispatch(blProgram())
		}
	}
}

UploadButton = connect(
	mapStateToProps,
	mapDispatchToProps
)(UploadButton)

export default UploadButton
