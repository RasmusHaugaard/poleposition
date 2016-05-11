import React, {PropTypes} from 'react'
import {connect} from 'react-redux'
import {LeftNav} from 'material-ui'
import MainRouteLink from '../containers/MainRouteLink.jsx'

let LeftNavPP = ({leftNavOpen}) => (
	<LeftNav open={leftNavOpen} width={150}>
		<div style={{height:"75px"}}></div>
		<MainRouteLink route={'Graph'}/>
		<MainRouteLink route={'Terminal'}/>
	</LeftNav>
)
LeftNavPP.propTypes = {
  leftNavOpen: PropTypes.bool.isRequired
}

const mapStateToProps = (state) => {
  return {
    leftNavOpen: state.leftNavOpen
  }
}

LeftNavPP = connect(
	mapStateToProps
)(LeftNavPP)

export default LeftNavPP
